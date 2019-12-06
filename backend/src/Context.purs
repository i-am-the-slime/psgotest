module Context where

import Prelude
import Cards.ElasticSearch (mkElasticSearchCardRepo)
import Cards.Types (CardRepo)
import Effect (Effect)

type Ctx
  = { cards ∷ CardRepo
    }

mkLiveCtx ∷ Effect Ctx
mkLiveCtx = do
  cards <- mkElasticSearchCardRepo
  pure { cards }
