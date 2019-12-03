{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "arrays"
    , "console"
    , "effect"
    , "parallel"
    , "parsing"
    , "psci-support"
    , "random"
    , "record-extra"
    , "simple-json"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}
