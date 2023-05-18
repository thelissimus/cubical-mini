{-# OPTIONS --safe #-}
module Meta.Literals where

open import Agda.Builtin.FromNat public
  using ( Number )
  renaming ( fromNat to from-nat )

open import Agda.Builtin.FromNeg public
  using ( Negative )
  renaming ( fromNeg to from-neg )

-- FIXME do not rename this!
open import Agda.Builtin.FromString public
  using ()
  renaming ( IsString   to is-string
           ; fromString to from-string )
