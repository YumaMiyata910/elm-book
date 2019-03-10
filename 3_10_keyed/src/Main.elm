module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    { items : List Item }


type alias Item =
    { id : String }


init : Model
init =
    Model []



-- UPDATE


type Msg
    = Add


update : Msg -> Model -> Model
update msg model =
    case msg of
        Add ->
            let
                item =
                    Item <| String.fromInt <| List.length model.items + 1
            in
            { model | items = item :: model.items }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Add ] [ text "Add" ]
        , Keyed.ul [] (List.map viewItem model.items)
        ]


viewItem : Item -> ( String, Html msg )
viewItem item =
    ( item.id
    , li [ class "item" ] [ text item.id ]
    )
