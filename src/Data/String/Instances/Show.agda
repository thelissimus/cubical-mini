{-# OPTIONS --safe #-}
module Data.String.Instances.Show where

open import Foundations.Base

open import Meta.Show

open import Data.String.Base

instance
  Show-string : Show String
  Show-string .shows-prec _ = show-string

_ : show "key: \"val\"" ＝ "\"key: \\\"val\\\"\""
_ = refl
