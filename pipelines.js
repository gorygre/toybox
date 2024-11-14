import { exec as execCb } from 'node:child_process'
import util from 'node:util'
const exec = util.promisify(execCb)

async function run(executable)
{
  console.log(`$ ${executable}`)
  console.log('==================================================================')
  const { stdout, stderr } = await exec(executable)
  console.log(stdout)
  console.error(stderr)
  console.log('==================================================================')
}

export const pipelines =
{
  'hs' : async (file, _) => {
    const executable = 'build/Main'
    const compiler = `ghc -outputdir build -o ${executable} ${file}`
    await run(compiler)
    await run(executable)
  },
  'awk' : async (file, ...args) => {
    const gawk = `gawk -f ${file} ` + args.join(' ')
    await run(gawk)
  },
  'html' : async (file, _) => {
    const dirname = file.substring(0, file.lastIndexOf('/'))
    const npx = `npx http-server ${dirname} -p 8080 --cors`
    await run(npx)
  }
}
