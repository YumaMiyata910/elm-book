module Main exposing (FooBar(..), foobar, foobarHelp)

import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import Json.Encode as Encode


type FooBar
    = Foo Int String
    | Bar Bool


foobar : Decoder FooBar
foobar =
    field "type" string
        |> andThen foobarHelp


foobarHelp : String -> Decoder FooBar
foobarHelp type_ =
    case type_ of
        "foo" ->
            map2 Foo
                (field "id" int)
                (field "name" string)

        "bar" ->
            Json.Decode.map Bar
                (field "flag" bool)

        _ ->
            fail "type should be one of [foo, bar]"


type alias Message =
    { timestamp : Float, data : Value }


messageDecoder : Decoder Message
messageDecoder =
    map2 Message
        (field "timestamp" float)
        (field "data" value)


getData : Decoder a -> Message -> Maybe a
getData decoder { data } =
    decodeValue decoder data
        |> Result.toMaybe


targetValueDecoder : Decoder String
targetValueDecoder =
    at [ "target", "value" ] string


type Msg
    = Input String


view : Html Msg
view =
    input [ on "input" (Json.Decode.map Input targetValueDecoder) ] []


tom : Encode.Value
tom =
    Encode.object
        [ ( "name", Encode.string "Tom" )
        , ( "age", Encode.int 42 )
        ]


compact =
    Encode.encode 0 tom


readable =
    Encode.encode 4 tom
