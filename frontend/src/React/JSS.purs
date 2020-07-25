module React.JSS (createUseStyles_, UseStyles) where

import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Prim.RowList (class RowToList)
import React.Basic.DOM (CSS)
import React.Basic.Hooks (Hook)
import Record.Extra (class MapRecord)

foreign import data UseStyles ∷ Type -> Type -> Type

foreign import createUseStylesImpl ∷
  ∀ css classNames.
  EffectFn1 {|css} (Hook (UseStyles { | css}) { | classNames })

-- foreign import makeStylesThemedImpl ∷
--   ∀ theme css classNames.
--   EffectFn1 ({|theme} -> {|css}) (Hook (UseStyles { | css}) { | classNames })

-- createUseStyles ∷
--   ∀ theme css cssList classNames.
--   RowToList css cssList =>
--   MapRecord cssList css CSS String () classNames =>
--   ({ | theme } -> { | css }) ->
--   Effect (Hook (UseStyles { | css }) { | classNames })
-- createUseStyles = runEffectFn1 createUseStylesThemedImpl

createUseStyles_ ∷
  ∀ css cssList classNames.
  RowToList css cssList =>
  MapRecord cssList css CSS String () classNames =>
  { | css } ->
  Effect (Hook (UseStyles { | css }) { | classNames })
createUseStyles_ = runEffectFn1 createUseStylesImpl