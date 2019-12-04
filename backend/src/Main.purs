module Main where

import Prelude

import Cards.Service (parseConvertedManaCost, toConvertedManaCost)
import Context (mkLiveCtx)
import Data.Array (zip)
import Data.Bifunctor (lmap)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Simple.JSON as JSON
import Gin (server)

main ∷ Effect Unit
main = do
  ctx <- mkLiveCtx
  -- res <- ctx.cards.search
  server ctx
  -- let
  --   boy = do
  --     (results ∷ Result CardRes) <- JSON.read res # lmap show
  --     let cards = results.hits.hits <#> _._source
  --     let manaCosts = cards <#> _.mana_cost
  --     let names = cards <#> _.name
  --     let images = cards <#> _.image_uris.large
  --     parsedManaCosts <- traverse parseConvertedManaCost manaCosts # lmap show

  --     pure $ (toConvertedManaCost <$> parsedManaCosts) `zip` names `zip` images
  -- logShow boy



-- httpReq "http://localhost:8081/scryfall-default-cards.json"
--     >>= either log (parseAndSaveCards ctx)
