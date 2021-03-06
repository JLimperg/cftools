module Examples where

import Grammar
import Algo

-- | example grammars

ex0 = CFG
      ['S', 'A']
      []
      [Production 'S' []
      ,Production 'S' [Left 'A']
      ,Production 'A' [Left 'A']]
      'S'

-- | simple expressions, left recursive
ex1left = CFG
      ['F', 'T']
      ['x', '+']
      [Production 'T' [Left 'F']
      ,Production 'T' [Left 'T', Right '+', Left 'F']
      ,Production 'F' [Right 'x']]  
      'T'

ex1right = CFG
      ['F', 'T']
      ['x', '+']
      [Production 'T' [Left 'F']
      ,Production 'T' [Left 'F', Right '+', Left 'T']
      ,Production 'F' [Right 'x']]  
      'T'

ex2 = CFG
      ['F']
      ['x', 'y']
      [Production 'F' [Right 'x']
      ,Production 'F' [Right 'y']]  
      'F'

ex3 = CFG
      ['F']
      ['x', 'y']
      [Production 'F' []
      ,Production 'F' [Right 'y', Left 'F']]  
      'F'

ex4 = CFG
      ['F']
      ['x', 'y']
      [Production 'F' []
      ,Production 'F' [Left 'F', Right 'y']]  
      'F'

-- | bracketed expressions, left recursive
ex5left = CFG
      ['F', 'T']
      ['x', '+', '(', ')']
      [Production 'T' [Left 'F']
      ,Production 'T' [Left 'T', Right '+', Left 'F']
      ,Production 'F' [Right 'x']
      ,Production 'F' [Right '(', Left 'T', Right ')']]
      'T'

ex5right = CFG
      ['F', 'T']
      ['x', '+', '(', ')']
      [Production 'T' [Left 'F']
      ,Production 'T' [Left 'F', Right '+', Left 'T']
      ,Production 'F' [Right 'x']
      ,Production 'F' [Right '(', Left 'T', Right ')']]  
      'T'

-- | L = { a^n b^n } 
ex6left = CFG
        ['S']
        "ab"
        [Production 'S' []
        ,Production 'S' [Right 'a', Left 'S', Right 'b']]
        'S'

ex6right = CFG
         ['R']
         "ab"
         [Production 'R' [Right 'a', Left 'R']
         ,Production 'R' [Right 'b', Left 'R']
         ,Production 'R' []]
         'R'

-- | L = { a^n b^m | m <= n } 
ex6leftb = CFG
        ['S']
        "ab"
        [Production 'S' []
        ,Production 'S' [Right 'a', Left 'S']
        ,Production 'S' [Right 'a', Left 'S', Right 'b']]
        'S'

ex6rightb = CFG
         ['R']
         "a"
         [Production 'R' [Right 'a', Left 'R']
         ,Production 'R' []]
         'R'

-- | L = same number of as and bs
ex6leftc = CFG
        ['S']
        "ab"
        [Production 'S' []
        ,Production 'S' [Right 'b', Left 'S', Right 'a']
        ,Production 'S' [Right 'a', Left 'S', Right 'b']
        ,Production 'S' [Left 'S', Left 'S']]
        'S'

-- | L = matching parentheses
ex7left = CFG
        ['S']
        "<>"
        [Production 'S' []
        ,Production 'S' [Right '<', Left 'S', Right '>']
        ,Production 'S' [Left 'S', Left 'S']]
        'S'
ex7right = CFG
         ['R']
         "<>"
         [Production 'R' [Right '<', Left 'R']
         ,Production 'R' [Right '>', Left 'R']
         ,Production 'R' []]
         'R'
