module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D exposing (Decoder)
import Route exposing (Route)
import Url
import Url.Builder



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | ErrorPage Http.Error
    | TopPage
    | UserRepo (List Repo)
    | RepoPage (List Issue)


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    -- 後で画面遷移で使うためのキーをModelに持たせておく
    Model key TopPage
        -- はじめてページを訪れたときも忘れずにページの初期化を行う
        |> goTo (Route.parse url)



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Loaded (Result Http.Error Page)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- 特に特別なことをしないときはこの実装でよいでしょう
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            -- ページの初期化処理をヘルパー関数に移譲
            goTo (Route.parse url) model

        Loaded result ->
            ( { model
                | page =
                    case result of
                        Ok page ->
                            page

                        Err e ->
                            -- 失敗したときはエラー用のページ
                            ErrorPage e
              }
            , Cmd.none
            )


{-| パスに応じて各ページを初期化する
-}
goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            -- 未定義のパスならNotFoundページを表示する
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            -- TopPageは即座にページを更新できる
            ( { model | page = TopPage }, Cmd.none )

        Just (Route.User userName) ->
            -- UserPageを取得
            ( model
            , Http.get
                { url =
                    Url.Builder.crossOrigin "https://api.github.com"
                        [ "users", userName, "repos" ]
                        []
                , expect =
                    Http.expectJson
                        (Result.map UserRepo >> Loaded)
                        reposDecoder
                }
            )

        Just (Route.Repo userName projectName) ->
            -- RepoPageを取得
            ( model
            , Http.get
                { url =
                    Url.Builder.crossOrigin "https://api.github.com"
                        [ "repos", userName, projectName, "issues" ]
                        []
                , expect =
                    Http.expectJson
                        (Result.map RepoPage >> Loaded)
                        issuesDecoder
                }
            )



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "My GitHub Viewer"
    , body =
        [ a [ href "/" ] [ h1 [] [ text "My GitHub Viewer" ] ]

        -- 場合分けしてページを表示する
        , case model.page of
            NotFound ->
                viewNotFound

            ErrorPage error ->
                viewError error

            TopPage ->
                viewTopPage

            UserRepo repos ->
                viewUserPage repos

            RepoPage issues ->
                viewRepoPage issues
        ]
    }


{-| NotFound ページ
-}
viewNotFound : Html msg
viewNotFound =
    text "not found"


{-| エラーページ
-}
viewError : Http.Error -> Html msg
viewError error =
    case error of
        Http.BadBody message ->
            pre [] [ text message ]

        _ ->
            text (Debug.toString error)


{-| トップページ
-}
viewTopPage : Html msg
viewTopPage =
    ul []
        -- ユーザー名を一覧にします
        -- 誰にしようか迷いますが、ひとまず決め打ちでこの2つにしておきます
        [ viewLink (Url.Builder.absolute [ "elm" ] [])
        , viewLink (Url.Builder.absolute [ "evancz" ] [])
        ]


{-| ユーザーページ
-}
viewUserPage : List Repo -> Html msg
viewUserPage repos =
    ul []
        -- ユーザーの持っているリポジトリのURLを一覧で表示します
        (repos
            |> List.map
                (\repo ->
                    viewLink (Url.Builder.absolute [ repo.owner, repo.name ] [])
                )
        )


{-| リポジトリのIssueページ
-}
viewRepoPage : List Issue -> Html msg
viewRepoPage issues =
    -- リポジトリのIssueを一覧で表示します
    ul [] (List.map viewIssue issues)


viewIssue : Issue -> Html msg
viewIssue issue =
    li []
        [ span [] [ text ("[" ++ issue.state ++ "]") ]
        , span [] [ text ("#" ++ String.fromInt issue.number) ]
        , span [] [ text issue.title ]
        ]


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]



-- GITHUB


type alias Repo =
    { name : String
    , description : String
    , language : Maybe String
    , owner : String
    , fork : Int
    , star : Int
    , watch : Int
    }


type alias Issue =
    { number : Int
    , title : String
    , state : String
    }


reposDecoder : Decoder (List Repo)
reposDecoder =
    D.list repoDecoder


repoDecoder : Decoder Repo
repoDecoder =
    D.map7 Repo
        (D.field "name" D.string)
        (D.field "description" D.string)
        (D.maybe (D.field "language" D.string))
        (D.at [ "owner", "login" ] D.string)
        (D.field "forks_count" D.int)
        (D.field "stargazers_count" D.int)
        (D.field "watchers_count" D.int)


issuesDecoder : Decoder (List Issue)
issuesDecoder =
    D.list issueDecoder


issueDecoder : Decoder Issue
issueDecoder =
    D.map3 Issue
        (D.field "number" D.int)
        (D.field "title" D.string)
        (D.field "state" D.string)
