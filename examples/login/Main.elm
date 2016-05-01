import Html exposing(div, text, button, img, small, a)
import Html.Attributes exposing(src, href)
import Html.Events exposing(onClick)
import Effects exposing (Effects, Never)
import Json.Decode
import StartApp
import Task
import Facebook
import Debug

-- login.html sends values to this signal
port facebookEvents: Signal Facebook.Event

type Action
  = NoOp
  | FacebookRequest  Facebook.Action
  | FacebookResponse Facebook.Action

app =
  StartApp.start
  { init = init
  , view = view
  , update = update
  , inputs = inputs
  }

main = app.html

-- execute tasks for effects
port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

-- initial actions at application startup
-- we listen for when FB api has loaded
inputs =
  [
   Signal.map (FacebookRequest << Facebook.eventToAction) facebookEvents
  ]

init =
  ( initialModel, Effects.none )

initialModel =
  { facebook = Facebook.initialModel
  , name = Nothing
  }

-- Just perform Facebook.update and tag resulting effects
updateOnFacebookRequest tag request model =
  let
    (fb_model, fb_effects) = Facebook.update request model.facebook
    new_model = { model | facebook = fb_model}
    fb_responses = Effects.map tag fb_effects
  in
    (new_model, fb_responses)

update action model =
  -- Uncomment for debugging all reactions
  -- let _ = Debug.log "update" (action, model) in
  case action of
    -- Transform fb events into effects
    FacebookRequest request ->
      updateOnFacebookRequest FacebookResponse request model

    -- Reset name when user has logged out
    FacebookResponse (Facebook.Did (Facebook.Logout)) ->
      ({model | name = Nothing}, Effects.none)

    -- When user logins request her info via graph api
    FacebookResponse (Facebook.Did (Facebook.Login)) ->
      let
        requestUserInfo = FacebookRequest (Facebook.GET "me")
      in
        ( model, Task.succeed requestUserInfo |> Effects.task )

    -- When got me, extract the user name from response
    FacebookResponse (Facebook.DidValue (Facebook.GET "me") jsonValue) ->
      let
        decoder = Json.Decode.at ["name"] Json.Decode.string
        decoded = Json.Decode.decodeValue decoder jsonValue
        new_model =
          case decoded of
            Err _ -> { model | name = Nothing }
            Ok name -> { model | name = Just name }
      in
        ( new_model, Effects.none )

    -- Handle all your app actions here
    _ ->
      ( model, Effects.none )

view address model =
  div
    []
    [
      case model.facebook.ready of
        False ->
          text "Loading Facebook API"
        True ->
          facebookLoginView address model
    , div
        []
        [ a [href "http://github.com/vic/elm-facebook"] [text "github.com/vic/elm-facebook"]
        ]
    ]

username name =
  case name of
    Nothing -> ""
    Just x -> x

facebookLoginView address {facebook, name} =
  div
    []
    [ div [] [text "ELM Facebook Login Example"]
    , case facebook.id of
        Nothing ->
          button
            [onClick (Signal.forwardTo address FacebookRequest) Facebook.Login]
            [text "Login with Facebook"]
        Just id ->
          div
            []
            [ div [] [img [src ("http://graph.facebook.com/" ++ id ++ "/picture?type=large")] []]
            , div [] [text <| "Welcome " ++ (username name) ]
            , button
                [onClick (Signal.forwardTo address FacebookRequest) Facebook.Logout]
                [text "Logout"]
            ]
    ]
