port module Main exposing (main, tick)

import Time



-- ElmからJavaScript側に数値を送信するための関数


port tick : Int -> Cmd msg


main =
    Platform.worker
        { init = \model -> ( 1, tick model )
        , update = \_ model -> ( model + 1, tick model )
        , subscriptions = \_ -> Time.every 1000 (\_ -> ())
        }
