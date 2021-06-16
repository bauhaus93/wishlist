port module Ports exposing (message_receiver)


port message_receiver : (String -> msg) -> Sub msg
