{-# OPTIONS --safe #-}
module Foundations.Sigma.Properties where

open import Foundations.Base
open import Foundations.Cubes
open import Foundations.Equiv.Base
open import Foundations.Equiv.Properties
open import Foundations.HLevel.Base
open import Foundations.Isomorphism
open import Foundations.Transport

private variable
  ℓ ℓ′ ℓ″ ℓ‴ : Level
  A : Type ℓ
  A′ : Type ℓ′
  B P : A → Type ℓ″
  Q : A → Type ℓ‴

-- Unique existence

∃! : (A : Type ℓ) (B : A → Type ℓ′) → Type (ℓ ⊔ ℓ′)
∃! A B = is-contr (Σ[ a ꞉ A ] B a)

infixr 6 ∃!-syntax
∃!-syntax : (A : Type ℓ) (B : A → Type ℓ′) → Type (ℓ ⊔ ℓ′)
∃!-syntax = ∃!

syntax ∃!-syntax A (λ x → B) = ∃![ x ꞉ A ] B

open Iso

Σ-pathᴾ-iso
  : {A : I → Type ℓ} {B : (i : I) → A i → Type ℓ′}
    {x : Σ (A i0) (B i0)} {y : Σ (A i1) (B i1)}
  → Σ[ p ꞉ ＜ x .fst ／ A ＼ y .fst ＞ ] ＜ x .snd ／ (λ i → B i (p i)) ＼ y .snd ＞
  ≅ ＜ x ／ (λ i → Σ (A i) (B i)) ＼ y ＞
Σ-pathᴾ-iso .to (p , q) i = p i , q i
Σ-pathᴾ-iso .from p = (λ i → p i .fst) , (λ i → p i .snd)
Σ-pathᴾ-iso .inverses .Inverses.inv-o = refl
Σ-pathᴾ-iso .inverses .Inverses.inv-i = refl

Σ-path-iso
  : {A : Type ℓ} {B : A → Type ℓ′} {x y : Σ A B}
  → Σ[ p ꞉ x .fst ＝ y .fst ] (subst B p (x .snd) ＝ y .snd)
  ≅ (x ＝ y)
Σ-path-iso {B} {x} {y} = transport
  (λ i → (Σ[ p ꞉ x .fst ＝ y .fst ] (pathᴾ=path (λ j → B (p j)) (x .snd) (y .snd) i))
       ≅ (x ＝ y))
  Σ-pathᴾ-iso

×-path : {B : Type ℓ′} {a c : A} {b d : B}
       → a ＝ c → b ＝ d → (a , b) ＝ (c , d)
×-path ac bd i = (ac i , bd i)

×-path-inv : {B : Type ℓ′} {a c : A} {b d : B}
       → (a , b) ＝ (c , d) → (a ＝ c) × (b ＝ d)
×-path-inv p = ap fst p , ap snd p

Σ-ap-snd : {A : Type ℓ} {P : A → Type ℓ′} {Q : A → Type ℓ″}
         → Π[ x ꞉ A ] (P x ≃ Q x) → Σ A P ≃ Σ A Q
Σ-ap-snd {A} {P} {Q} pointwise = ≅→≃ morp where
  pwise : Π[ x ꞉ A ] (P x ≅ Q x)
  pwise = ≃→≅ ∘ pointwise

  morp : Σₜ _ P ≅ Σₜ _ Q
  morp .to = second λ {i} → pointwise i .fst
  morp .from = second λ {i} → pwise i .from
  morp .inverses .Inverses.inv-o = fun-ext λ (i , x) → ap² _,_ refl (pwise i .inv-o # x)
  morp .inverses .Inverses.inv-i = fun-ext λ (i , x) → ap² _,_ refl (pwise i .inv-i # x)

Σ-ap-fst : (e : A ≃ A′) → Σₜ A (B ∘ e .fst) ≃ Σₜ A′ B
Σ-ap-fst {A} {A′} {B} e = intro , intro-is-equiv
 where
  intro : Σₜ _ (B ∘ e .fst) → Σₜ _ B
  intro (a , b) = e .fst a , b

  intro-is-equiv : is-equiv intro
  intro-is-equiv .equiv-proof x = ctr , is-ctr where
    PB : ∀ {x y} → x ＝ y → B x → B y → Type _
    PB p b₀ b₁ = ＜ b₀ ／ (λ i → B (p i)) ＼ b₁ ＞

    open Σₜ x renaming (fst to a′; snd to b)
    open Σₜ (e .snd .equiv-proof a′ .fst) renaming (fst to A-ctr; snd to α)

    B-ctr : B (e .fst A-ctr)
    B-ctr = subst B (sym α) b

    P-ctr : PB α B-ctr b
    P-ctr i = coe1→i (λ i → B (α i)) i b

    ctr : fibre intro x
    ctr = (A-ctr , B-ctr) , Σ-pathᴾ α P-ctr

    is-ctr : ∀ y → ctr ＝ y
    is-ctr ((r , s) , p) = λ i → (a=r i , b≠s i) , α=ρ i ,ₚ coh i where
      open Σₜ (Σ-pathᴾ-iso .from p) renaming (fst to ρ; snd to σ)
      open Σₜ (Σ-pathᴾ-iso .from (e .snd .equiv-proof a′ .snd (r , ρ)))
        renaming (fst to a=r; snd to α=ρ)

      b≠s : PB (ap (e .fst) a=r) B-ctr s
      b≠s i = comp (λ k → B (α=ρ i (~ k))) (∂ i) λ where
        k (i = i0) → P-ctr (~ k)
        k (i = i1) → σ (~ k)
        k (k = i0) → b

      coh : ＜ P-ctr ／ (λ i → PB (α=ρ i) (b≠s i) b) ＼ σ ＞
      coh i j = fill (λ k → B (α=ρ i (~ k))) (∂ i) (~ j) λ where
        k (i = i0) → P-ctr (~ k)
        k (i = i1) → σ (~ k)
        k (k = i0) → b

Σ-ap : {A : Type ℓ} {A′ : Type ℓ′} {P : A → Type ℓ″} {Q : A′ → Type ℓ‴}
       (e : A ≃ A′)
     → Π[ a ꞉ A ] (P a ≃ Q (e .fst a))
     → Σ A P ≃ Σ A′ Q
Σ-ap e e′ = Σ-ap-snd e′ ∙ Σ-ap-fst e

×-ap : {B : Type ℓ′} {C : Type ℓ″} {D : Type ℓ‴}
     → A ≃ C → B ≃ D → A × B ≃ C × D
×-ap ac bd = Σ-ap ac (λ _ → bd)

Σ-retract-fst : (r : Retractₜ A A′) → Retractₜ (Σₜ A B) (Σₜ A′ (B ∘ r .fst))
Σ-retract-fst {B} (f , hs) .fst (a′ , b) = f a′ , b
Σ-retract-fst {B} (f , hs) .snd .section (a , b) =
  hs .section a , subst B (sym (hs .is-section # a)) b
Σ-retract-fst {B} (f , hs) .snd .is-section = fun-ext λ (a , b)
  →  hs .is-section # a
  ,ₚ subst⁻-filler B (hs .is-section # a) b ⁻¹

Σ-retract-snd : {A : Type ℓ} {P : A → Type ℓ′} {Q : A → Type ℓ″}
              → Π[ x ꞉ A ] Retractₜ (P x) (Q x) → Retractₜ (Σ A P) (Σ A Q)
Σ-retract-snd pw .fst = second λ {x} → pw x .fst
Σ-retract-snd pw .snd .section = second (λ {x} → pw x .snd .section)
Σ-retract-snd pw .snd .is-section = fun-ext λ (a , p) → refl ,ₚ pw a .snd .is-section # p

Σ-assoc : {A : Type ℓ} {B : A → Type ℓ′} {C : (a : A) → B a → Type ℓ″}
        → Σ[ x ꞉ A ] Σ[ y ꞉ B x ] C x y
        ≃ Σ[ (x , y) ꞉ Σₜ _ B ] C x y
Σ-assoc .fst (x , y , z) = (x , y) , z
Σ-assoc .snd .equiv-proof y .fst = strict-contr-fibres (λ { ((x , y) , z) → x , y , z}) y .fst
Σ-assoc .snd .equiv-proof y .snd = strict-contr-fibres (λ { ((x , y) , z) → x , y , z}) y .snd

×-assoc : {B : Type ℓ′} {C : Type ℓ″}
        → A × B × C ≃ (A × B) × C
×-assoc = Σ-assoc

Σ-Π-distrib : {A : Type ℓ} {B : A → Type ℓ′} {C : (x : A) → B x → Type ℓ″}
            → Π[ x ꞉ A ] Σ[ y ꞉ B x ] C x y
            ≃ Σ[ f ꞉ Π[ x ꞉ A ] B x ] Π[ x ꞉ A ] C x (f x)
Σ-Π-distrib .fst f = (λ x → f x .fst) , λ x → f x .snd
Σ-Π-distrib .snd .equiv-proof y .fst = strict-contr-fibres (λ f x → f .fst x , f .snd x) y .fst
Σ-Π-distrib .snd .equiv-proof y .snd = strict-contr-fibres (λ f x → f .fst x , f .snd x) y .snd

Σ-prop-pathᴾ
  : {A : I → Type ℓ} {B : ∀ i → A i → Type ℓ′}
  → (∀ i x → is-prop (B i x))
  → {x : Σ (A i0) (B i0)} {y : Σ (A i1) (B i1)}
  → ＜ x .fst ／ A ＼ y .fst ＞
  → ＜ x ／ (λ i → Σ (A i) (B i)) ＼ y ＞
Σ-prop-pathᴾ bp {x} {y} p i =
  p i , is-prop→pathᴾ (λ i → bp i (p i)) (x .snd) (y .snd) i

Σ-prop-path : (∀ x → is-prop (B x))
            → {x y : Σₜ _ B}
            → (x .fst ＝ y .fst) → x ＝ y
Σ-prop-path B-pr = Σ-prop-pathᴾ (λ _ → B-pr)

Σ-prop-path-is-equiv
  : (bp : ∀ x → is-prop (B x))
  → {x y : Σₜ _ B}
  → is-equiv (Σ-prop-path bp {x} {y})
Σ-prop-path-is-equiv bp {x} {y} = qinv→is-equiv spi where
  spi : quasi-inverse (Σ-prop-path bp)
  spi .quasi-inverse.inv = ap fst
  spi .quasi-inverse.inverses .Inverses.inv-i = refl
  spi .quasi-inverse.inverses .Inverses.inv-o i p j
    = p j .fst
    , is-prop→pathᴾ (λ k → path-is-of-hlevel-same 1 (bp (p k .fst))
                                      {x = Σ-prop-path bp {x} {y} (ap fst p) k .snd}
                                      {y = p k .snd})
                             refl refl j i

Σ-prop-path-≃ : (∀ x → is-prop (B x))
              → {x y : Σₜ _ B}
              → (x .fst ＝ y .fst) ≃ (x ＝ y)
Σ-prop-path-≃ bp = Σ-prop-path bp , Σ-prop-path-is-equiv bp

Σ-square
  : ∀ {ℓ ℓ'} {A : Type ℓ} {B : A → Type ℓ'}
  → {w x y z : Σₜ _ B}
  → {p : x ＝ w} {q : x ＝ y} {r : y ＝ z} {s : w ＝ z}
  → (θ : Square (ap fst p) (ap fst q) (ap fst r) (ap fst s))
  → Squareᴾ (λ i j → B (θ i j)) (ap snd q) (ap snd p) (ap snd s) (ap snd r)
  → Square p q r s
Σ-square θ ζ i j = θ i j , ζ i j

Σ-prop-square
  : ∀ {ℓ ℓ'} {A : Type ℓ} {B : A → Type ℓ'}
  → {w x y z : Σₜ _ B}
  → (∀ x → is-prop (B x))
  → {p : x ＝ w} {q : x ＝ y} {r : y ＝ z} {s : w ＝ z}
  → Square (ap fst p) (ap fst q) (ap fst r) (ap fst s)
  → Square p q r s
Σ-prop-square B-prop {p} {q} {r} {s} θ = Σ-square θ
  (is-prop→squareᴾ (λ i j → B-prop (θ i j)) (ap snd q) (ap snd p) (ap snd s) (ap snd r))

Σ-contract-fst : {A : Type ℓ} {B : A → Type ℓ′}
                 (A-c : is-contr A)
               → Σ[ x ꞉ A ] B x ≃ B (centre A-c)
Σ-contract-fst {B} A-c = ≅→≃ the-iso where
  the-iso : _ ≅ _
  the-iso .to (x , b) = subst B (paths A-c x ⁻¹) b
  the-iso .from = centre A-c ,_
  the-iso .inverses .Inverses.inv-o = fun-ext λ b′ → sym
    $ subst-filler B refl b′
    ∙ ap (λ f → subst B f b′) (is-contr→is-prop (path-is-of-hlevel-same 0 A-c) _ _)
  the-iso .inverses .Inverses.inv-i = fun-ext λ (x , b) →
    paths A-c x ,ₚ subst-filler B (paths A-c x ⁻¹) b ⁻¹

Σ-contract-snd : (∀ x → is-contr (B x)) → Σ A B ≃ A
Σ-contract-snd B-contr = ≅→≃ $ iso fst (_, centre (B-contr _)) refl
  λ i (a , b) → a , paths (B-contr a) b i

Σ-inj-set
  : ∀ {x y z}
  → is-set A
  → Path (Σₜ A B) (x , y) (x , z)
  → y ＝ z
Σ-inj-set {B} {y} {z} A-set path =
  subst (_＝ z) (ap (λ e → transport (ap B e) y) (A-set _ _ _ _) ∙ transport-refl y)
    (from-pathᴾ (ap snd path))

Σ-swap
  : {A : Type ℓ} {B : Type ℓ′} {C : A → B → Type ℓ″}
  → Σ[ x ꞉ A ] Σ[ y ꞉ B ] C x y
  ≃ Σ[ y ꞉ B ] Σ[ x ꞉ A ] C x y
Σ-swap .fst (x , y , f) = y , x , f
Σ-swap .snd .equiv-proof = strict-contr-fibres _

×-swap : {B : Type ℓ′} → A × B ≃ B × A
×-swap .fst (x , y) = y , x
×-swap .snd .equiv-proof = strict-contr-fibres _

curry-≃ : {A : Type ℓ} {B : A → Type ℓ′} {C : (x : A) → B x → Type ℓ″}
        → Π[ x ꞉ A ] Π[ y ꞉ B x ] C x y
        ≃ Π[ (x , y) ꞉ Σ[ x ꞉ A ] B x ] C x y
curry-≃ = ≅→≃ $ iso _$²_ curry² refl refl


-- Automation

Σ-prop-pathᴾ!
  : {A : I → Type ℓ} {B : ∀ i → A i → Type ℓ′}
  → ⦃ ∀ {i x} → H-Level 1 (B i x) ⦄
  → {x : Σ (A i0) (B i0)} {y : Σ (A i1) (B i1)}
  → ＜ x .fst ／ A ＼ y .fst ＞
  → ＜ x ／ (λ i → Σ (A i) (B i)) ＼ y ＞
Σ-prop-pathᴾ! = Σ-prop-pathᴾ (λ _ _ → hlevel 1)

Σ-prop-path!
  : ⦃ B-pr : ∀ {x} → H-Level 1 (B x) ⦄
  → {x y : Σₜ A B}
  → x .fst ＝ y .fst
  → x ＝ y
Σ-prop-path! = Σ-prop-pathᴾ!

Σ-inj-set!
  : ∀ {x y z}
  → ⦃ A-set : H-Level 2 A ⦄
  → Path (Σₜ A B) (x , y) (x , z)
  → y ＝ z
Σ-inj-set! = Σ-inj-set (hlevel 2)

Σ-prop-square!
  : ∀ {ℓ ℓ'} {A : Type ℓ} {B : A → Type ℓ'}
  → {w x y z : Σₜ _ B}
  → ⦃ ∀ {x} → H-Level 1 (B x) ⦄
  → {p : x ＝ w} {q : x ＝ y} {r : y ＝ z} {s : w ＝ z}
  → Square (ap fst p) (ap fst q) (ap fst r) (ap fst s)
  → Square p q r s
Σ-prop-square! = Σ-prop-square (λ _ → hlevel 1)
