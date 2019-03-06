module Components.FileUpload exposing (Msg, Model, init, update, upload)


import Bytes exposing (Bytes)
import File exposing (File)
import File.Select as Select
import Http
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Task


type Msg
    = FileRequested
    | Selected File
    | UploadConfirmed File
    | FileSent (Result Http.Error ())


type UploadState
    = NoFileSelected
    | FileSelected File
    | Uploading
    | Uploaded


type alias Model =
    { uploadState : UploadState
    , mimeType : String
    , url : String
    }


init : String -> String -> Model
init mimeType url =
    { uploadState = NoFileSelected
    , mimeType = mimeType
    , url = url
    }


uploadFile : File -> String -> Cmd Msg
uploadFile file url =
    Http.post
        { url = url ++ "/" ++ File.name file
        , body = Http.fileBody file
        , expect = Http.expectWhatever FileSent
        }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FileRequested ->
            ( model, Select.file [model.mimeType] Selected )

        Selected file ->
            ( { model | uploadState = FileSelected file }, Cmd.none )

        UploadConfirmed file ->
            ( model, uploadFile file model.url )

        FileSent _ ->
            ( { model | uploadState = Uploaded }, Cmd.none )


upload : Model -> Html Msg
upload model =
    case model.uploadState of
        NoFileSelected ->
            button [ onClick FileRequested ] [ text "Upload" ]

        FileSelected file ->
            div []
                [ div [] [ text <| "Selected: " ++ File.name file ]
                , div [] [ button [ onClick (UploadConfirmed file) ] [ text "Confirm" ] ]
                ]

        Uploading ->
            div [] [ text "Uploading..." ]

        Uploaded ->
            div [] [ text "Upload complete" ]
