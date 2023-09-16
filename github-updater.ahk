#Include ..\Bruno-Functions\ImportAllList.ahk

Class Git{
    __New(username, repository, version := "tag_name", use_prefix := false, version_prefix := "v") {
        this.username := username
        this.repository := repository
        this.__version_name := version
        this.__use_prefix := use_prefix
        this.__version_prefix := version_prefix
        this.url := "https://api.github.com/repos/" username "/" repository "/releases/latest"
        this.ini := Ini(A_Temp "\github.ini")
        this.online := false
        this.__Load(this.url)
    }

    __Load(url){
        if !IsOnline()
            return false

        try{
            this.body := GetPageContent(this.url)
            JsonToIni(this.body, this.ini.path, "body")
            this.assets := this.ini["body", "assets"]
            JsonToIni(this.assets, this.ini.path, "assets", , true)
            this.latest_url := this.ini["assets", "browser_download_url"]
            
            this.version := this.ini["body", this.__version_name]
            if this.__use_prefix && InStr(this.version, this.__version_prefix){
                this.version := StrSplit(this.version, this.__version_prefix)
                this.version := this.version[this.version.Length]
            }

            this.extension := StrSplit(this.latest_url, ".")
            this.extension := this.extension[this.extension.Length]
            this.update_message := this.ini["body", "body"]
            this.online := true
            return true
        }
        return false
    }

    GetUpdateMessage(){
        if this.online
            return this.update_message
        return false
    }

    GetLatestUrl(){
        if this.online
            return this.latest_url
        return false
    }

    GetVersion(){
        if this.online
            return this.version
        return false
    }

    GetExtension(){
        if this.online
            return "." this.extension
        return false
    }

    Reload(){
        return this.__Load(this.url)
    }

    ExitAppFunc(){
        ExitApp()
    }

    DownloadLatest(download_where, filename){
        if !this.online
            return false

        if !InStr(filename, ".")
            filename .= this.GetExtension()

        try{
            downloadFile(this.latest_url, download_where "\" filename, , , this.ExitAppFunc)
            return true
        }
        catch Error as e{
            return false
        }
    }
}
