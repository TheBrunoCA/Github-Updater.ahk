#Include ..\Bruno-Functions\GetPageContent.ahk
#Include ..\Bruno-Functions\JsonToIni.ahk
#Include ..\Bruno-Functions\BatWrite.ahk

/*
@Credit to samfisherirl (https://github.com/samfisherirl/github.ahk)
*/
Class Git {
    __New(p_user, p_repo) {
        this.user := p_user
        this.repo := p_repo
        this.url := "https://api.github.com/repos/" this.user "/" this.repo "/releases/latest"
        this.ini_path := A_AppData "\" this.user "\" this.repo "\github.ini"
        this.body := GetPageContent(this.url)
        this.body := JsonToIni(this.body, this.ini_path, "body")

        if this.body == ""
        {
            this.is_online := false
            return
        }
        try
        {
            if IniRead(this.ini_path, "body", "message") == "Not Found"
            {
                this.is_online := false
                return
            }
        }
        this.is_online := true

        this.assets := IniRead(this.ini_path, "body", "assets")
        this.assets := JsonToIni(this.assets, this.ini_path, "assets", , true)

        this.dl_url := IniRead(this.ini_path, "assets", "browser_download_url")

        this.version := IniRead(this.ini_path, "body", "tag_name")
        this.version := StrSplit(this.version, "v")
        this.version := this.version[this.version.Length]

        this.extension := StrSplit(this.dl_url, ".")
        this.extension := this.extension[this.extension.Length]
    }

    Download(p_path_to_save, p_filename){
        Download(this.dl_url, p_path_to_save "\" p_filename "." this.extension)
    }

    /*
    Checks if the current installed version is up to date with the github latest release.
    @Param version The current installed version.
    @Return True if updated or False if not updated.
    */
    IsUpdated(p_version){
        if(this.is_online == false){
            return true
        }
        if p_version < this.version{
            return false
        }
        return true
    }

    /*
    Downloads from github and replaces the executable or script and creates a shortcut.
    @Param p_install_path Where to install the update
    */
    UpdateApp(p_install_path){
        ; baixar versao atualizada em temp
        ; criar arquivo com nome FP-Extra-Updated.txt em temp com a mensagem de atualizacao
        ; deletar arquivo bat em temp
        ; escrever arquivo bat em temp
        ; abrir arquivo bat
        ; fechar app
        ; o arquivo bat ira:
        ; esperar 1 segundo para app fechar
        ; deletar o app no working dir
        ; mover o app para appdata
        ; criar um shortcut do app na area de trabalho
        ; abrir o app e fechar

        ; O app aberto ira checar para ver se FP-Extra-Updated.txt existe em temp
        ; Se sim irá ler a mensagem e mostrar ela. Logo apos ira apagar o arquivo.
        ; Apagar o icone em appdata
        ; baixar o icone em appdata e qualquer outro recurso que precisa ser atualizado
        ; Isso apenas se conseguir baixar o icone, se nao mantem o antigo.

        this.Download(A_Temp, this.repo)
        FileAppend(IniRead(this.ini_path, "body", "body", "Successfully updated!"), A_Temp "\" this.repo "-Updated.txt")
        bat_file := A_Temp "\update-bat.bat"
        
        bat_file := BatWrite(bat_file)
        bat_file.TimeOut(1)
        bat_file.DeleteFile(A_ScriptFullPath)
        bat_file.MoveFile(A_Temp "\" this.repo "." this.extension
        , p_install_path "\" this.repo "." this.extension)
        bat_file.CreateShortcut(p_install_path "\" this.repo "." this.extension
        , A_Desktop "\" this.repo ".lnk")
        bat_file.Start(p_install_path "\" this.repo "." this.extension)

        Run(bat_file.path, , "Hide")
        ExitApp(1000)
        
        
        
        
        
        ; download_path := A_Temp "\" p_app_name "." p_git_hub.GetExtension()
        ; If(FileExist(download_path != "")){
        ;     FileDelete(download_path)
        ; }
        ; bat_file := A_Temp "\" p_app_name "_batch.bat"
        ; if(FileExist(bat_file) != ""){
        ;     FileDelete(bat_file)
        ; }
        ; ; Write batch
        ; ; Download update
        ; ; Update version
        ; ; MsgBox
        ; ; Run batch
        ; ; ExitApp()
        ; FileAppend("timeout /t 1 /nobreak",bat_file)

        ; EnvSet("DeleteThisFile", A_WorkingDir "\" p_app_name "." p_git_hub.GetExtension())
        ; FileAppend("`ndel `"%DeleteThisFile%`"",bat_file)

        ; EnvSet("MoveThis", download_path)
        ; EnvSet("MoveThere", A_WorkingDir)
        ; FileAppend("`nmove /y `"%MoveThis%`" `"%MoveThere%`"",bat_file)

        ; EnvSet("StartThis", A_WorkingDir "\" p_app_name "." p_git_hub.GetExtension())
        ; FileAppend("`nstart `"`" `"%StartThis%`"",bat_file)
        
        ; FileAppend("`ntimeout /t 2 /nobreak",bat_file)
        
        ; p_git_hub.Download(A_Temp, p_app_name)

        ; IniWrite p_git_hub.GetVersion(), p_version_path, "version", p_app_name

        ; MsgBox("A Aplicação foi atualizada e será reiniciada automaticamente, apenas aguarde.", p_app_name " atualizado!")
        ; Run(bat_file, , "Hide")
        ; ExitApp()
    }
}