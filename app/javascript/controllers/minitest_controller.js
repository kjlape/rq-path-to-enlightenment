import { Controller } from '@hotwired/stimulus'
import { File, OpenFile, PreopenDirectory, WASI } from '@bjorn3/browser_wasi_shim'

// Matches Minitest's summary line, e.g. "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips".
// The s? variants are defensive; Minitest itself always uses the plural words.
const MINITEST_SUMMARY_RE = /(\d+)\s+runs?,\s*(\d+)\s+assertions?,\s*(\d+)\s+failures?,\s*(\d+)\s+errors?,\s*(\d+)\s+skips?/g

// Pure: extract the last Minitest summary line from runner output, or null if none is found.
export function parseMinitestSummary (output) {
  const matches = [...String(output).matchAll(MINITEST_SUMMARY_RE)]
  const last = matches[matches.length - 1]
  if (!last) return null

  const [, runs, assertions, failures, errors, skips] = last
  return {
    runs: Number(runs),
    assertions: Number(assertions),
    failures: Number(failures),
    errors: Number(errors),
    skips: Number(skips)
  }
}

// Pure: given the raw Minitest#run return value and the runner output,
// decide what verdict the UI should show.
export function minitestVerdict (resultPassed, output) {
  const summary = parseMinitestSummary(output)

  // No summary line at all: fall back to the old result-based behavior.
  if (!summary) return resultPassed ? '✅' : '❌'

  if (summary.runs === 0) return '⚠️ No tests ran'
  if (summary.failures + summary.errors + summary.skips > 0) return '❌'
  if (summary.assertions === 0) {
    const noun = summary.runs === 1 ? 'test' : 'tests'
    return `⚠️ ${summary.runs} ${noun} ran, but no assertions`
  }

  return '✅'
}

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
  static targets = ['code', 'output', 'status', 'runButton']
  static values = { saveUrl: String, answerUrl: String, challengeId: Number, autorun: Boolean }

  connect () {
    this.vm = null
    this.vmReady = false
    this.running = false
    this.spinnerTimer = null
    this.saving = false
    this.warmInTheBackground()
    this.connectAutorun()

    if (!this.hasSaveUrlValue) return

    this.savedCode = this.currentCode
    this.handleInput = () => this.refreshStatus()
    this.handleBeforeUnload = (event) => {
      if (this.dirty) {
        event.preventDefault()
        event.returnValue = '' // required for Chrome to show the dialog
      }
    }
    this.handleTurboBeforeVisit = (event) => {
      if (this.dirty && !window.confirm('You have unsaved changes. Leave anyway?')) {
        event.preventDefault()
      }
    }
    this.codeTarget.addEventListener('input', this.handleInput)
    window.addEventListener('beforeunload', this.handleBeforeUnload)
    document.addEventListener('turbo:before-visit', this.handleTurboBeforeVisit)
  }

  disconnect () {
    this.stopSpinner()
    this.disconnectAutorun()

    if (!this.hasSaveUrlValue) return

    this.codeTarget.removeEventListener('input', this.handleInput)
    window.removeEventListener('beforeunload', this.handleBeforeUnload)
    document.removeEventListener('turbo:before-visit', this.handleTurboBeforeVisit)
  }

  async run () {
    if (this.running) return
    this.running = true
    this.setButtonsBusy(true, 'Loading VM…')

    try {
      this.outputTarget.textContent = ''
      this.runnerOutput = ''

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

      const verdict = minitestVerdict(result.toJS() === true, this.runnerOutput)
      this.outputTarget.textContent += verdict
      if (verdict === '✅' && this.hasAnswerUrlValue) await this.saveAnswer()
    } catch (error) {
      this.stopSpinner()
      this.outputTarget.textContent = `Failed to load Ruby VM: ${error}`
      this.vm = null
      this.vmReady = false
      this.autorunQueued = false
    } finally {
      this.running = false
      this.setButtonsBusy(false)
      this.runFinished()
    }
  }

  // Debounced auto-run for the challenge editor: tests re-run as the user
  // types, and a passing run submits the answer.
  connectAutorun () {
    if (!this.autorunValue || !this.hasAnswerUrlValue) return

    this.handleAutoInput = () => {
      clearTimeout(this.autorunTimer)
      this.autorunTimer = setTimeout(() => {
        // run() guards against overlapping runs; if one is in flight, try
        // again when it finishes.
        if (this.running) {
          this.autorunQueued = true
        } else {
          this.run()
        }
      }, 750)
    }
    this.codeTarget.addEventListener('input', this.handleAutoInput)
  }

  disconnectAutorun () {
    if (!this.handleAutoInput) return

    clearTimeout(this.autorunTimer)
    this.codeTarget.removeEventListener('input', this.handleAutoInput)
  }

  runFinished () {
    if (this.autorunQueued && !this.running) {
      this.autorunQueued = false
      this.run()
    }
  }

  // Shared JSON transport for save() and saveAnswer(); callers own the
  // status messaging. Throws on a non-OK response.
  async submitJson (method, url, payload) {
    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify(payload)
    })

    if (!response.ok) throw new Error((await this.errorMessage(response)) || 'Request failed')
    return response
  }

  async saveAnswer () {
    if (this.savingAnswer) return
    this.savingAnswer = true
    this.showStatus('Submitting answer…')

    try {
      await this.submitJson('POST', this.answerUrlValue, {
        challenge_answer: {
          challenge_id: this.challengeIdValue,
          submitted_code: this.currentCode,
          passed: true
        }
      })
      this.showStatus('✅ Tests passed — answer saved')
    } catch {
      this.showStatus('Could not save answer', true)
    } finally {
      this.savingAnswer = false
    }
  }

  async save (event) {
    if (!this.hasSaveUrlValue || this.saving) return
    this.saving = true
    const code = this.currentCode
    this.showStatus('Saving…')

    try {
      await this.submitJson('PATCH', this.saveUrlValue, {minitest_test_class: {code}})
      this.savedCode = code
      this.showStatus('Saved')
      setTimeout(() => {
        if (!this.dirty) this.hideStatus()
      }, 2500)
    } catch (error) {
      this.showStatus(error.message || 'Could not save', true)
    } finally {
      this.saving = false
    }
  }

  get currentCode () {
    return this.codeTarget.value || this.codeTarget.textContent
  }

  get dirty () {
    return this.hasSaveUrlValue && this.currentCode !== this.savedCode
  }

  refreshStatus () {
    if (this.dirty) {
      this.showStatus('Unsaved changes')
    } else {
      this.hideStatus()
    }
  }

  showStatus (message, isError = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle('text-red-500', isError)
    this.statusTarget.classList.toggle('text-gray-500', !isError)
    this.statusTarget.hidden = false
  }

  hideStatus () {
    this.statusTarget.textContent = ''
    this.statusTarget.hidden = true
  }

  async errorMessage (response) {
    try {
      return Object.values(await response.json()).flat()[0]
    } catch {
      return null
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
    this.runnerOutput += str
    this.outputTarget.textContent += str
  }

  stderr (str) {
    this.runnerOutput += str
    this.outputTarget.textContent += str
  }
}
