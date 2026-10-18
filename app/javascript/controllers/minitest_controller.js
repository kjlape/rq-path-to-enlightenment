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

export default class extends Controller {
  static targets = ['code', 'output']

  async run (event) {
    this.outputTarget.textContent = ''
    this.runnerOutput = ''

    this.vm ||= this.createRubyVM()

    const result = await (await this.vm).evalAsync(this.rubyCode)
      .catch(e => {
        this.outputTarget.textContent += e
        return e
      })

    this.outputTarget.textContent += minitestVerdict(result.toJS() === true, this.runnerOutput)
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
    this.runnerOutput += str
    this.outputTarget.textContent += str
  }

  stderr (str) {
    this.runnerOutput += str
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
