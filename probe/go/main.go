package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
)

type realmResponse struct {
    Realm string `json:"realm"`
}

func main() {
    realm := getenv("REALM", "sony.net")
    port := getenv("PORT", "3000")

    mux := http.NewServeMux()

    mux.HandleFunc("/realm", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/plain; charset=utf-8")
        fmt.Fprintf(w, "%s\n", realm)
    })

    mux.HandleFunc("/realm.json", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json; charset=utf-8")
        json.NewEncoder(w).Encode(realmResponse{Realm: realm})
    })

    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/plain; charset=utf-8")
        fmt.Fprintln(w, "ok")
    })

    addr := ":" + port
    log.Printf("realm probe listening on %s (realm=%s)", addr, realm)
    if err := http.ListenAndServe(addr, mux); err != nil {
        log.Fatal(err)
    }
}

func getenv(key, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}

