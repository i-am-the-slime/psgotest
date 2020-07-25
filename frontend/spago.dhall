{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
    [ "console"
    , "debug"
    , "effect"
    , "milkis"
    , "parsing"
    , "psci-support"
    , "react-basic-hooks"
    , "react-basic-storybook"
    , "record-extra"
    , "remotedata"
    , "simple-json"
    ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
