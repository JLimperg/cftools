module Algo where

import Data.List (sort, nub, (\\))

import Grammar
import Util

-- | emptiness check
emptyLanguage :: (Ord n) => CFG n t -> n -> Bool
emptyLanguage (CFG nts ts ps _) start = 
    not (start `elem` usefulNts ps [])

usefulNts :: (Ord n) => [Production n t] -> [n] -> [n]
usefulNts ps init = 
    fixpoint (usefulStep ps) init

usefulStep :: Ord n => [Production n t] -> [n] -> [n]
usefulStep ps assumed =
    dropRepeated $ sort [nt | p@(Production nt alpha) <- ps, usefulProduction p assumed]

usefulProduction :: Eq n => Production n t -> [n] -> Bool
usefulProduction (Production nt alpha) assumed =
    all (usefulSymbol assumed) alpha

usefulSymbol :: (Eq n) => [n] -> Symbol n t -> Bool
usefulSymbol assumed (Right t) = True
usefulSymbol assumed (Left n)  = n `elem` assumed

-- | nullable check -- does L contain the empty word?
nullableLanguage :: (Ord n) => CFG n t -> n -> Bool
nullableLanguage (CFG _ _ ps _) start =
    start `elem` nullableNts ps []

nullableNts :: (Ord n) => [Production n t] -> [n] -> [n]
nullableNts ps init =
    fixpoint (nullableStep ps) init

nullableStep :: Ord n => [Production n t] -> [n] -> [n]
nullableStep ps assumed =
    dropRepeated $ sort [nt | Production nt alpha <- ps, all (nullableSymbol assumed) alpha]

nullableSymbol :: (Eq n) => [n] -> Symbol n t -> Bool
nullableSymbol assumed (Right t) = False
nullableSymbol assumed (Left n)  = n `elem` assumed

-- | reduce -- keep only productions for useful NTs
reduceGrammar :: (Eq n) => CFG n t -> [n] -> CFG n t
reduceGrammar (CFG nts ts ps start) usefulNts =
    CFG nts ts ps' start
    where
    ps' = [Production nt alpha | Production nt alpha <- ps, all (usefulSymbol usefulNts) alpha]

-- | a reduced CFG packaged with useful NTs and nullable NTs
mkRCFG :: (Ord n) => CFG n t -> RCFG n t
mkRCFG cfg@ (CFG _ _ ps _) = 
    let useful = usefulNts ps []
        redcfg@ (CFG _ _ redps _) = reduceGrammar cfg useful
    in
    RCFG redcfg useful (nullableNts redps [])

-- | reduce productions with respect to an existing reduced grammar
-- yields the remaining useful productions, the useful nonterminals, and
-- the nullable nonterminals
reduceProductions :: (Ord n) =>
                     RCFG n t -> [Production n t] -> ([Production n t], [n], [n])
reduceProductions rcfg ps =
    let nUseful = usefulNts ps (useful rcfg)
        nPs = [p | p <- ps, usefulProduction p nUseful]
        nNullable = nullableNts nPs (nullable rcfg) 
    in (nPs, nUseful, nNullable)

type Substitution n = [(n, n)]

-- | match new productions with new lhs nonterminals to existing productions
-- cannot do this one at a time because productions may be mutually recursive
-- result is a substitution S of nonterminals: 
-- * new productions can be removed for each n in dom(S)
-- * S must be applied to the right hand sides of the new productions
-- * S must be applied to the new start symbol
matchProductions :: (Eq n) => RCFG n t -> [Production n t] -> Substitution n
matchProductions rcfg ps = 
    undefined

-- | derivative -- should better be done with a proper monad...
derivative :: (Eq n, Eq t) => RCFG (n,[t]) t -> t -> CFG (n,[t]) t
derivative (RCFG cfg@(CFG nts ts ps start) useful nullable) t =
    CFG (newNTs ++ nts) ts (newPs ++ ps) (deriveNT start t)
    where
    (newNTs, newPs) = worker [start] [] ([], [])
    -- NTs to consider, NTs already processed, (accumlated nts and productions)
    worker [] processed nps =
        nps
    worker nts0@(nt:nts) processed (nts', ps') = 
        let ntprods = [Production n alpha | Production n alpha <- ps, n == nt] 
            newNT   = deriveNT nt t
            (newprods, candidates) = processProductions newNT ntprods [] []
            considerNTs = (nub candidates \\ processed) \\ nts0
        in
        worker (considerNTs ++ nts) (nt:processed) (newNT : nts', newprods ++ ps')

    -- 
    processProductions newNT [] newprods candidates =
        (newprods, candidates)
    processProductions newNT (Production nt alpha:ps) newprods candidates =
        let (rhss, candidates') = deriveAlpha alpha in
        processProductions newNT ps ([Production newNT alpha' | alpha' <- rhss] ++ newprods)
                               (candidates' ++ candidates)

    deriveAlpha [] =
        ([], [])
    deriveAlpha (Left nt:rest) = 
        if nt `elem` nullable
        then let (rhss, candidates) = deriveAlpha rest in
             ((Left (deriveNT nt t):rest) : rhss, nt : candidates)
        else ([Left (deriveNT nt t):rest], [nt])
    deriveAlpha (Right t':rest) =
        if t==t'
        then ([rest], [])
        else ([], [])

    deriveNT (n, ts) t =
        (n, t:ts)
