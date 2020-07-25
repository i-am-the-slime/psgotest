module Card.Stories where

import Prelude hiding (add)

import Card.Component (mkCard)
import Cards.Types (Card)
import Data.Either (either)
import Data.Foldable (foldMap)
import Effect (Effect)
import Foreign (renderForeignError)
import Partial.Unsafe (unsafeCrashWith)
import Simple.JSON (readJSON)
import Storybook.React (Storybook, add, storiesOf)

stories ∷ Effect Storybook
stories = do
  storiesOf "Card" do
    -- addDecorator fullScreenDecorator
    add "Example card" mkCard
      [ { card: exampleCard }
      ]

exampleCard ∷ Card
exampleCard = either (unsafeCrashWith <<< foldMap renderForeignError) identity $
 readJSON
 """
   {"object":"card","id":"5cda8633-2661-4fa7-81b0-3ae535619a3c","oracle_id":"47a785ed-8095-4685-8daa-02c4e2b0ffcd","multiverse_ids":[],"name":"Spellseeker","lang":"en","released_at":"2020-01-01","uri":"https://api.scryfall.com/cards/5cda8633-2661-4fa7-81b0-3ae535619a3c","scryfall_uri":"https://scryfall.com/card/j20/3/spellseeker?utm_source=api","layout":"normal","highres_image":true,"image_uris":{"small":"https://img.scryfall.com/cards/small/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.jpg?1575405124","normal":"https://img.scryfall.com/cards/normal/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.jpg?1575405124","large":"https://img.scryfall.com/cards/large/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.jpg?1575405124","png":"https://img.scryfall.com/cards/png/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.png?1575405124","art_crop":"https://img.scryfall.com/cards/art_crop/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.jpg?1575405124","border_crop":"https://img.scryfall.com/cards/border_crop/front/5/c/5cda8633-2661-4fa7-81b0-3ae535619a3c.jpg?1575405124"},"mana_cost":"{2}{U}","cmc":3.0,"type_line":"Creature — Human Wizard","oracle_text":"When Spellseeker enters the battlefield, you may search your library for an instant or sorcery card with converted mana cost 2 or less, reveal it, put it into your hand, then shuffle your library.","power":"1","toughness":"1","colors":["U"],"color_identity":["U"],"legalities":{"standard":"not_legal","future":"not_legal","historic":"not_legal","pioneer":"not_legal","modern":"not_legal","legacy":"legal","pauper":"not_legal","vintage":"legal","penny":"not_legal","commander":"legal","brawl":"not_legal","duel":"legal","oldschool":"not_legal"},"games":["paper"],"reserved":false,"foil":true,"nonfoil":false,"oversized":false,"promo":true,"reprint":true,"variation":false,"set":"j20","set_name":"Judge Gift Cards 2020","set_type":"promo","set_uri":"https://api.scryfall.com/sets/1b90366b-7692-44ea-bd55-f17fa92869a5","set_search_uri":"https://api.scryfall.com/cards/search?order=set&q=e%3Aj20&unique=prints","scryfall_set_uri":"https://scryfall.com/sets/j20?utm_source=api","rulings_uri":"https://api.scryfall.com/cards/5cda8633-2661-4fa7-81b0-3ae535619a3c/rulings","prints_search_uri":"https://api.scryfall.com/cards/search?order=released&q=oracleid%3A47a785ed-8095-4685-8daa-02c4e2b0ffcd&unique=prints","collector_number":"3","digital":false,"rarity":"rare","watermark":"judgeacademy","flavor_text":"Not content with mere answers, she hunts for the truth.","card_back_id":"0aeebaf5-8c7d-4636-9e82-8c27447861f7","artist":"Anna Podedworna","artist_ids":["1874cb2c-f690-475f-a217-c14f11166758"],"illustration_id":"1b689979-a14d-442a-b946-2ba9d4364d79","border_color":"black","frame":"2015","full_art":false,"textless":false,"booster":false,"story_spotlight":false,"promo_types":["judgegift"],"edhrec_rank":648,"related_uris":{"tcgplayer_decks":"https://decks.tcgplayer.com/magic/deck/search?contains=Spellseeker&page=1&partner=Scryfall&utm_campaign=affiliate&utm_medium=scryfall&utm_source=scryfall","edhrec":"https://edhrec.com/route/?cc=Spellseeker","mtgtop8":"https://mtgtop8.com/search?MD_check=1&SB_check=1&cards=Spellseeker"}}
 """