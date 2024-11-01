import { pipelines } from './pipelines.js'
import yargs from 'yargs'
import { hideBin } from 'yargs/helpers'
import { open } from 'node:fs/promises'

const cmd = 
  yargs(hideBin(process.argv))
    .option('file', {
      alias: 'f',
      type: 'string',
      description: 'Path to toy to run'
    })
    .demandOption('file')
const argv = cmd.argv

async function readConfig(basename) {
  try {
    const handle = await open(`${basename}.json`, 'r')
    return handle.readFile('utf8')
  } catch (err) {
    if (err.code === 'ENOENT') {
      // a config is not required
      return ''
    }

    throw err
  }
}

async function parseConfig(basename) {
  const content = await readConfig(basename)
  if (content === '')
  {
    return []
  }

  // allow to throw -- if config present it should parse
  return JSON.parse(content)
}

async function main() {
  const split = argv.file.split('.')
  const basename = split[0]
  const ext = split[1]
  if (argv.file === '') {
    cmd.showHelp()
    console.error('Require argument --file cannot be empty')
    return
  }

  // could further parse with yargs if it is helpful
  const config = await parseConfig(basename)
  const args = (process.argv.length < 5) ? config.args : process.argv.slice(4)

  if (!(ext in pipelines)) {
    cmd.showHelp()
    console.error(`No pipeline found for ${argv.file}`)
    console.error('Define one in pipelines.js')
    return
  }

  await pipelines[ext](argv.file, ...args)
}

main()
