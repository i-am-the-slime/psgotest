module Elasticsearch where

import Prelude

import Data.Newtype (class Newtype, unwrap)
import Effect (Effect)
import Foreign (Foreign)
import Simple.JSON (class ReadForeign, class WriteForeign)

foreign import data EsClient ∷ Type
foreign import mkDefaultClient ∷ Effect EsClient
foreign import info ∷ EsClient -> Effect String
foreign import mkIndexRequestImpl ∷
  String -> String -> String -> IndexRequest
foreign import index ∷ EsClient -> IndexRequest -> Effect String
foreign import searchImpl ∷ EsClient -> String -> String -> Effect Foreign

search ∷ EsClient -> Index -> String -> Effect Foreign
search client (Index idx) = searchImpl client idx

foreign import data IndexRequest ∷ Type
mkIndexRequest ∷ Index -> DocId -> Body -> IndexRequest
mkIndexRequest idx docid body =
  mkIndexRequestImpl (unwrap idx) (unwrap docid) (unwrap body)

newtype Index = Index String
derive instance ntIndex ∷ Newtype Index _
derive newtype instance readForeignIndex ∷ ReadForeign Index
derive newtype instance writeForeignIndex ∷ WriteForeign Index
derive newtype instance eqIndex ∷ Eq Index

newtype DocId = DocId String
derive instance ntDocId ∷ Newtype DocId _
derive newtype instance readForeignDocId ∷ ReadForeign DocId
derive newtype instance writeForeignDocId ∷ WriteForeign DocId
derive newtype instance eqDocId ∷ Eq DocId

newtype Body = Body String
derive instance ntBody ∷ Newtype Body _
derive newtype instance readForeignBody ∷ ReadForeign Body
derive newtype instance writeForeignBody ∷ WriteForeign Body
derive newtype instance eqBody ∷ Eq Body
