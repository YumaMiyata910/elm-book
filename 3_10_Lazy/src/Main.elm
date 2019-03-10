module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    { first : Int
    , second : Int
    }


init : Model
init =
    Model 0 0



-- UPDATE


type Msg
    = IncrementFirst
    | IncrementSecond


update : Msg -> Model -> Model
update msg model =
    case msg of
        IncrementFirst ->
            { model | first = model.first + 1 }

        IncrementSecond ->
            { model | second = model.second + 1 }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewCount model.first
        , button [ onClick IncrementFirst ] [ text "+" ]
        , lazy viewCount model.second
        , button [ onClick IncrementSecond ] [ text "+" ]
        ]


viewCount : Int -> Html Msg
viewCount count =
    div [] [ text (String.fromInt count) ]
