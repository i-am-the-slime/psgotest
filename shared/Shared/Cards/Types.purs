module Cards.Types where

import Prelude
import Data.Maybe (Maybe)
import Effect (Effect)

type CardRepo
  = { write ∷ Card -> Effect Unit
    , search ∷ String -> Effect (Array Card)
    }

type ImageUris
  = { art_crop ∷ String
    , border_crop ∷ String
    , large ∷ String
    , normal ∷ String
    , png ∷ String
    , small ∷ String
    }

type Legalities
  = { brawl ∷ String
    , commander ∷ String
    , duel ∷ String
    , future ∷ String
    , historic ∷ String
    , legacy ∷ String
    , modern ∷ String
    , oldschool ∷ String
    , pauper ∷ String
    , penny ∷ String
    , pioneer ∷ String
    , standard ∷ String
    , vintage ∷ String
    }

type RelatedUris
  = { edhrec ∷ String
    , mtgtop8 ∷ String
    , tcgplayer_decks ∷ String
    }

type Card
  = { artist ∷ String
    , artist_ids ∷ Maybe (Array String)
    , booster ∷ Boolean
    , border_color ∷ String
    , card_back_id ∷ String
    , cmc ∷ Number
    , collector_number ∷ String
    , color_identity ∷ Array String
    , colors ∷ Maybe (Array String)
    , digital ∷ Boolean
    , edhrec_rank ∷ Maybe Int
    , flavor_text ∷ Maybe String
    , foil ∷ Boolean
    , frame ∷ String
    , full_art ∷ Boolean
    , games ∷ Array String
    , hand_modifier ∷ Maybe String
    , highres_image ∷ Boolean
    , id ∷ String
    , illustration_id ∷ Maybe String
    , image_uris ∷ Maybe ImageUris
    , lang ∷ String
    , layout ∷ String
    , legalities ∷ Legalities
    , life_modifier ∷ Maybe String
    , loyalty ∷ Maybe String
    , mana_cost ∷ Maybe String
    , multiverse_ids ∷ Array Int
    , name ∷ String
    , nonfoil ∷ Boolean
    , object ∷ String
    , oracle_id ∷ String
    , oracle_text ∷ Maybe String
    , oversized ∷ Boolean
    , power ∷ Maybe String
    , prints_search_uri ∷ String
    , promo ∷ Boolean
    , promo_types ∷ Maybe (Array String)
    , rarity ∷ String
    , related_uris ∷ RelatedUris
    , released_at ∷ String
    , reprint ∷ Boolean
    , reserved ∷ Boolean
    , rulings_uri ∷ String
    , scryfall_set_uri ∷ String
    , scryfall_uri ∷ String
    , set ∷ String
    , set_name ∷ String
    , set_search_uri ∷ String
    , set_type ∷ String
    , set_uri ∷ String
    , story_spotlight ∷ Boolean
    , tcgplayer_id ∷ Maybe Int
    , textless ∷ Boolean
    , toughness ∷ Maybe String
    , type_line ∷ String
    , uri ∷ String
    , variation ∷ Boolean
    , "watermark" ∷ Maybe String
    }

type CardFace
  = { artist ∷ Maybe String -- The name of the illustrator of this card face. Newly spoiled cards may not have this field yet.
    , color_indicator ∷ Array String -- The colors in this face’s color indicator, if any.
    , colors ∷ Array String -- This face’s colors, if the game defines colors for the individual face of this card.
    , flavor_text ∷ String -- The flavor text printed on this face, if any.
    , illustration_id ∷ String -- A unique identifier for the card face artwork that remains consistent across reprints. Newly spoiled cards may not have this field yet.
    , image_uris ∷ ImageUris -- An object providing URIs to imagery for this face, if this is a double-sided card. If this card is not double-sided, then the image_uris property will be part of the parent object instead.
    , loyalty ∷ Maybe String -- This face’s loyalty, if any.
    , mana_cost ∷ String --The mana cost for this face. This value will be any empty string "" if the cost is absent. Remember that per the game rules, a missing mana cost and a mana cost of {0} are different values.
    , name ∷ String -- The name of this particular face. object String  A content type for this object, always card_face.
    , oracle_text ∷ Maybe String -- The Oracle text for this face, if any.
    , power ∷ Maybe String -- This face’s power, if any. Note that some cards have powers that are not numeric, such as *.
    , printed_name ∷ Maybe String -- The localized name printed on this face, if any.
    , printed_text ∷ Maybe String -- The localized text printed on this face, if any.
    , printed_type_line ∷ Maybe String -- The localized type line printed on this face, if any.
    , toughness ∷ Maybe String -- This face’s toughness, if any.
    , type_line ∷ String -- The type line of this particular face.
    , watermark ∷ Maybe String -- The watermark on this particulary card face, if any.
    }
