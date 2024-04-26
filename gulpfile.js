const { series } = require('gulp')
const exec = require('child_process').exec
const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const argv = yargs(hideBin(process.argv)).argv

function ghc(cb, file)
{
  const compiler = 'ghc -outputdir build -o build/Main ' + file
  console.log(compiler)
  exec(compiler, function(error, stdout, stderr)
    {
      console.log(stdout)
      console.log(stderr)
      cb()
    })
}

const build =
{
  "hs" : ghc
}

function execMain(cb, file)
{
  const executable = 'build/Main'
  console.log(executable)
  exec(executable, function(error, stdout, stderr)
    {
      console.log(stdout)
      console.log(stderr)
      cb()
    })
}

const run =
{
  "hs" : execMain
}

function buildSnippet(cb)
{
  const ext = argv.file.split('.').pop()
  build[ext](cb, argv.file);
}

function runSnippet(cb)
{
  const ext = argv.file.split('.').pop()
  run[ext](cb, argv.file);
}

exports.default = series(buildSnippet, runSnippet)
