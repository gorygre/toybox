package main

import "fmt"
import "log"
import "html"
import "net/http"
import "os/exec"
import "os"
import "strconv"

func main() {
  fmt.Println("listening at localhost:8080/dectalk")

  file := 1;

  tmpDirName, err := os.MkdirTemp("", "wavs")
  if err != nil {
    fmt.Println("error creating temporary directory")
    fmt.Println(err)
  }
  defer os.RemoveAll(tmpDirName)

  http.HandleFunc("/dectalk", func(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
      w.WriteHeader(http.StatusMethodNotAllowed)
      fmt.Fprintf(w, "Please POST dectalk input")
      return
    }

    w.Header().Set("Access-Control-Allow-Origin", "*")

    buf := make([]byte, 1024)
    n, err := r.Body.Read(buf)
    if err != nil {
      fmt.Println("reading error")
      fmt.Println(err)
    }
    content := string(buf[:n])

    msg := fmt.Sprintf("%q", html.EscapeString(r.URL.Path))
    msg += "\n"
    msg += content
    fmt.Println(msg)

    if content == "" {
      fmt.Println("returning early because content is empty")
      return
    }

    path := tmpDirName + "/" + strconv.Itoa(file) + ".wav"
    file++

    cmd := exec.Command("/Users/mccall/projects/dectalk/dist/say", "-pre", "[:PHONE ON]", "-a", content, "-fo", path)
    fmt.Println(cmd.String())
    if err := cmd.Run(); err != nil {
      fmt.Println("===FATAL===")
      log.Fatal(err)
    }

    fmt.Println("Output dectalk to " + path)

    data, err := os.ReadFile(path)
    if err != nil {
      fmt.Println("audio reading error")
      log.Fatal(err)
    }

    w.Write(data)
  })

  log.Fatal(http.ListenAndServe(":8080", nil))
}
