import { Controller } from '@hotwired/stimulus'
import { File, OpenFile, PreopenDirectory, WASI } from '@bjorn3/browser_wasi_shim'

const RUBY_LIB_URL = 'https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.6.2/dist/index.umd.js'
const RUBY_WASM_URL = 'https://cdn.jsdelivr.net/npm/@ruby/3.3-wasm-wasi@2.6.2/dist/ruby+stdlib.wasm'

// Shared across every minitest controller on the page (a page can hold many
// Run buttons) so the ~30 MB wasm is downloaded and compiled at most once.
let rubyRuntimePromise = null

function warmRubyRuntime () {
  if (!rubyRuntimePromise) {
    rubyRuntimePromise = Promise.all([importUMD(RUBY_LIB_URL), compileRubyModule()])
    rubyRuntimePromise.catch(() => { rubyRuntimePromise = null }) // allow a retry after a failed download
  }
  return rubyRuntimePromise
}

function compileRubyModule () {
  return WebAssembly.compileStreaming( // eslint-disable-line no-undef
    fetch(RUBY_WASM_URL)
  )
}

async function importUMD (url, module = { exports: {} }) {
  return (
    Function( // eslint-disable-line no-new-func
      'module',
      'exports',
      await (
        await fetch(url)
      ).text()
    ).call(module, module, module.exports), module).exports
}

export default class extends Controller {
  static targets = ['code', 'output', 'runButton']

  connect () {
    this.vm = null
    this.vmReady = false
    this.running = false
    this.spinnerTimer = null
    this.warmInTheBackground()
  }

  disconnect () {
    this.stopSpinner()
  }

  async run () {
    if (this.running) return
    this.running = true
    this.setButtonsBusy(true, 'Loading VM…')

    try {
      this.outputTarget.textContent = ''

      this.vm ||= this.createRubyVM()
      if (!this.vmReady) this.showLoadingIndicator()

      const vm = await this.vm
      this.vmReady = true
      this.stopSpinner()
      this.outputTarget.textContent = '' // replace the loading message with real output

      this.setButtonsBusy(true, 'Running…')

      const result = await vm.evalAsync(this.rubyCode)
        .catch(e => {
          this.outputTarget.textContent += e
          return e
        })

      if (result.toJS() === true) {
        this.outputTarget.textContent += '✅'
      } else {
        this.outputTarget.textContent += '❌'
      }
    } catch (error) {
      this.stopSpinner()
      this.outputTarget.textContent = `Failed to load Ruby VM: ${error}`
      this.vm = null
      this.vmReady = false
    } finally {
      this.running = false
      this.setButtonsBusy(false)
    }
  }

  // Fetch and compile the Ruby runtime during idle time so the first Run
  // doesn't start from a cold ~30 MB download. Skipped in automated browsers
  // so tests don't pull the wasm in the background.
  warmInTheBackground () {
    if (navigator.webdriver) return

    const warm = () => { warmRubyRuntime() }
    if ('requestIdleCallback' in window) {
      requestIdleCallback(warm, { timeout: 5000 })
    } else {
      setTimeout(warm, 1500)
    }
  }

  async createRubyVM () {
    const [{ RubyVM, consolePrinter }, module] = await warmRubyRuntime()

    const args = []
    const env = []
    const fds = [
      new OpenFile(new File([])),
      new OpenFile(new File([])),
      new OpenFile(new File([])),
      new PreopenDirectory('/', new Map())
    ]
    const wasi = new WASI(args, env, fds, { debug: false })
    const vm = new RubyVM()

    const imports = {
      wasi_snapshot_preview1: wasi.wasiImport
    }
    vm.addToImports(imports)
    const printer = consolePrinter({
      stdout: this.stdout.bind(this),
      stderr: this.stderr.bind(this)
    })
    printer.addToImports(imports)

    const instance = await WebAssembly.instantiate( // eslint-disable-line no-undef
      module,
      imports
    )
    await vm.setInstance(instance)

    printer.setMemory(instance.exports.memory)

    wasi.initialize(instance)
    vm.initialize()
    vm.eval(this.rubySetupCode)

    return vm
  }

  showLoadingIndicator () {
    this.stopSpinner()
    const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
    let frame = 0
    const render = () => {
      this.outputTarget.textContent = `Loading Ruby VM… ${frames[frame % frames.length]}`
    }
    render()
    this.spinnerTimer = setInterval(() => {
      frame += 1
      render()
    }, 120)
  }

  stopSpinner () {
    if (this.spinnerTimer) {
      clearInterval(this.spinnerTimer)
      this.spinnerTimer = null
    }
  }

  setButtonsBusy (busy, busyLabel = 'Running…') {
    this.runButtonTargets.forEach((button) => {
      if (busy) {
        button.dataset.label ||= button.textContent
        button.textContent = busyLabel
      } else if (button.dataset.label) {
        button.textContent = button.dataset.label
      }
      button.disabled = busy
    })
  }

  get rubyCode () {
    return `
    ${this.codeTarget.value || this.codeTarget.textContent}
    ${this.rubyAfterUserCode}
    `
  }

  get rubySetupCode () {
    return `
require 'minitest/test'
FakeParallelExecutor = Struct.new(:shutdown)
Minitest.parallel_executor = FakeParallelExecutor.new
`
  }

  get rubyAfterUserCode () {
    return `
    Minitest.run
    `
  }

  stdout (str) {
    this.outputTarget.textContent += str
  }

  stderr (str) {
    this.outputTarget.textContent += str
  }
}
