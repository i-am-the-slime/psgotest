module Cards.ElasticSearch where

import Prelude
import Cards.Types (CardRepo, Card)
import Data.Either (either)
import Data.Foldable (foldMap)
import Effect (Effect)
import Effect.Class.Console (log, logShow)
import Effect.Unsafe (unsafePerformEffect)
import Elasticsearch as ES
import Foreign (Foreign, renderForeignError)
import Simple.JSON (class WriteForeign, write, writeJSON)
import Simple.JSON as JSON

mkElasticSearchCardRepo ∷ Effect CardRepo
mkElasticSearchCardRepo = do
  client <- ES.mkDefaultClient
  info <- ES.info client
  logShow info
  pure
    { write:
      \(card ∷ Card) -> do
        let
          req =
            ES.mkIndexRequest
              (ES.Index "cards")
              (ES.DocId card.id)
              (ES.Body (writeJSON card))
        void $ ES.index client req
    , search:
      \str -> do
        res <- ES.search client (ES.Index "cards") (writeJSON $ exampleQuery str)
        let
          results = JSON.read res
        let
          bla = results <#> (\(r ∷ Result Card) -> r.hits.hits <#> _._source)
        pure (either (\e -> let _ = spy "shit" (foldMap renderForeignError e) in []) identity bla)
    }

spy msg str = unsafePerformEffect <<< log

-- type CardRes
--   = { mana_cost ∷ String
--     , name ∷ String
--     , oracle_text ∷ String
--     , set_name ∷ String
--     , image_uris ∷ { large ∷ String }
--     }
type Result a
  = { _shards ∷
      { failed ∷ Int
      , skipped ∷ Int
      , successful ∷ Int
      , total ∷ Int
      }
    , hits ∷
      { hits ∷
        Array
          { _id ∷ String
          , _index ∷ String
          , _score ∷ Number
          , _source ∷ a
          , _type ∷ String
          }
      , max_score ∷ Number
      , total ∷
        { relation ∷ String
        , value ∷ Int
        }
      }
    , timed_out ∷ Boolean
    , took ∷ Int
    }

json ∷ ∀ a. WriteForeign a => a -> Foreign
json = write

exampleQuery ∷ String -> Foreign
exampleQuery s =
  json
    { "size": 5
    -- , "_source": [ "name", "oracle_text", "mana_cost", "set_name", "img", "image_uris.large" ]
    , "query":
      { "bool":
        { "must":
          [
          -- [ json
          --     { "terms":
          --       { "legalities.standard.keyword":
          --         [ "legal"
          --         ]
          --       }
          --     }
           json
              { bool:
                { should:
                  [ json
                      { match:
                        { "oracle_text": s
                        }
                      }
                  , json
                      { match:
                        { "name": s
                        }
                      }
                  ]
                }
              }
          -- , json
          --     { "terms":
          --       { "rarity.keyword": [ "mythic" ]
          --       }
          --     }
          -- , json
          --     { "terms":
          --       { "set.keyword": [ "eld", "m20" ]
          --       }
          --     }
          ]
        }
      }
    }
