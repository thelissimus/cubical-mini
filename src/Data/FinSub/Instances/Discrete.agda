{-# OPTIONS --safe #-}
module Data.FinSub.Instances.Discrete where

open import Foundations.Base

open import Meta.Search.Discrete

open import Data.Dec.Base as Dec
open import Data.List.Base
open import Data.Nat.Base
open import Data.Nat.Instances.Discrete

open import Data.FinSub.Base

private variable @0 n : ℕ

instance
  fin-is-discrete : is-discrete (Fin n)
  fin-is-discrete = is-discrete-η λ k l → Dec.map
    fin-ext (λ k≠l p → k≠l (ap Fin.index p)) (Fin.index k ≟ Fin.index l)

  decomp-dis-fin : goal-decomposition (quote is-discrete) (Fin n)
  decomp-dis-fin = decomp (quote fin-is-discrete) []
