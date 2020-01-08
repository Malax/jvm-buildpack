package main

import (
    "fmt"
    "github.com/magiconair/properties"
    "net/http"
    "net/url"
    "os"
    "path"
    "regexp"
)

const defaultVendor = "openjdk"

func main() {
    switch os.Args[1] {
    case "read-version-string":
        readVersionStringOperation()
    case "version-from-version-string":
        versionFromVersionStringOperation()
    case "vendor-from-version-string":
        vendorFromVersionStringOperation()
    case "jdk-download-url":
        jdkDownloadUrlOperation()
    default:
        _, _ = fmt.Fprintln(os.Stderr, "No operation specified. Valid values are: read-version-string, version-from-version-string, vendor-from-version-string and jdk-download-url")
        os.Exit(1)
    }
}

func readVersionStringOperation() {
    if propertiesFile, err := properties.LoadFile(os.Args[2], properties.UTF8); err == nil {
        if value, ok := propertiesFile.Get("java.runtime.version"); ok {
            fmt.Println(value)
            os.Exit(0)
        }
    }

    os.Exit(1)
}

func versionFromVersionStringOperation() {
    _, version := resolveVersionString(os.Args[2])
    fmt.Println(version)
    os.Exit(0)
}

func vendorFromVersionStringOperation() {
    vendor, _ := resolveVersionString(os.Args[2])
    fmt.Println(vendor)
    os.Exit(0)
}


func jdkDownloadUrlOperation() {
    stack := os.Args[2]
    vendor := os.Args[3]
    version := os.Args[4]

    jdkUrl, urlParseErr := url.Parse("https://lang-jvm.s3.amazonaws.com/jdk/")
    if urlParseErr != nil {
        _, _ = fmt.Fprintln(os.Stderr, "Internal error: could not parse base URL!")
        os.Exit(1)
    }

    switch vendor {
    case "openjdk":
        jdkUrl.Path = path.Join(jdkUrl.Path, stack, "openjdk" + version + ".tar.gz")

    case "zulu":
        jdkUrl.Path = path.Join(jdkUrl.Path, stack, "zulu-" + version + ".tar.gz")

    default:
        _, _ = fmt.Fprintf(os.Stderr, "Unsupported vendor %s!", vendor)
        os.Exit(1)
    }

    if response, err := http.Head(jdkUrl.String()); err == nil && response.StatusCode == 200 {
        fmt.Println(jdkUrl.String())
        os.Exit(0)
    } else {
        _, _ = fmt.Fprintf(os.Stderr, "Could not determine valid download URL for %s %s %s!", stack, vendor, version)
        os.Exit(1)
    }
}

func resolveVersionString(version string) (string, string) {
    selectedVersion := version
    selectedVendor := defaultVendor

    switch selectedVersion {
    case "9.0.0", "9+181":
        version = "9-181"
        selectedVendor = "openjdk"
    default:
        vendorRegex := regexp.MustCompile("^([a-zA-Z]+?)-(.*)$")
        if matches := vendorRegex.FindAllStringSubmatch(selectedVersion, 1); matches != nil {
            selectedVendor = matches[0][1]
            selectedVersion = matches[0][2]
        }

        switch selectedVersion {
        case "7", "1.7":
            selectedVersion = "1.7.0_242"
        case "8", "1.8":
            selectedVersion = "1.8.0_232"
        case "9", "1.9":
            selectedVersion = "9.0.4"
        case "10":
            selectedVersion = "10.0.2"
        case "11":
            selectedVersion = "11.0.5"
        case "12":
            selectedVersion = "12.0.2"
        case "13":
            selectedVersion = "13.0.1"
        }
    }

    return selectedVendor, selectedVersion
}
