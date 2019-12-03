module Cards.ElasticSearch where

import Prelude

import Cards.Types (CardRepo, Card)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Elasticsearch as ES
import Foreign (Foreign)
import Simple.JSON (class WriteForeign, write, writeJSON)

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
    , search: ES.search client (ES.Index "cards") (writeJSON exampleQuery)
    }

json ∷ ∀ a. WriteForeign a => a -> Foreign
json = write

exampleQuery ∷ Foreign
exampleQuery =
  json
    { "size": 100
    , "_source": [ "name", "oracle_text", "mana_cost", "set_name", "img", "image_uris.large" ]
    , "query":
      { "bool":
        { "must":
          [ json
              { "terms":
                { "legalities.standard.keyword":
                  [ "legal"
                  ]
                }
              }
          , json
              { "match":
                { "oracle_text": "draw a card"
                }
              }
          , json
              { "terms":
                { "rarity.keyword": [ "mythic" ]
                }
              }
          , json
              { "terms":
                { "set.keyword": [ "eld", "m20" ]
                }
              }
          ]
        }
      }
    }
