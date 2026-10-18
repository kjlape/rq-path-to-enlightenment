import { Controller } from '@hotwired/stimulus'
import { File, OpenFile, PreopenDirectory, WASI } from '@bjorn3/browser_wasi_shim'

export default class extends Controller {
  static targets = ['code', 'output']

  async run (event) {
    this.outputTarget.textContent = ''

    this.vm ||= this.createRubyVM()

    const result = await (await this.vm).evalAsync(this.rubyCode)
      .catch(e => {
        this.outputTarget.textContent += e
        return e
      })

    if (result.toJS() === true) {
      this.outputTarget.textContent += '✅'
    } else {
      this.outputTarget.textContent += '❌'
    }
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

  async createRubyVM () {
    const { RubyVM, consolePrinter } = await this.importUMD('https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.6.2/dist/index.umd.js')

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

    const module = await WebAssembly.compileStreaming( // eslint-disable-line no-undef
      fetch('https://cdn.jsdelivr.net/npm/@ruby/3.3-wasm-wasi@2.6.2/dist/ruby+stdlib.wasm')
    )
    const instance = await WebAssembly.instantiate( // eslint-disable-line no-undef
      module,
      imports
    )
    await vm.setInstance(instance)

    printer.setMemory(instance.exports.memory)

    wasi.initialize(instance)
    vm.initialize()
    vm.eval(this.rubySetupCode)
    this.outputTarget.textContent = 'Ruby VM ready\n'

    return vm
  }

  stdout (str) {
    this.outputTarget.textContent += str
  }

  stderr (str) {
    this.outputTarget.textContent += str
  }

  async importUMD (url, module = { exports: {} }) {
    return (
      Function( // eslint-disable-line no-new-func
        'module',
        'exports',
        await (
          await fetch(url)
        ).text()
      ).call(module, module, module.exports), module).exports
  }
}
