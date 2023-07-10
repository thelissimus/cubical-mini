{-# OPTIONS --safe #-}
module Data.Unit.Instances.Discrete where

open import Foundations.Base

open import Meta.Search.Discrete

open import Data.Dec.Base
open import Data.Unit.Base public

instance
  ⊤-is-discrete : is-discrete ⊤
  ⊤-is-discrete = is-discrete-η λ _ _ → yes refl