module Bananaconda where
import Prelude hiding (Drop)




type Prog = [Cmd]


type Load = Stack -> Maybe Stack

type Stack = [Either Int String]

data Cmd = PushS String
         | PushI Int
         | Add
         | Equ
         | IfElse Prog Prog
         | While Prog
         | Size_of_stack
         | Randverb Int
         | Randnoun Int
         | Randadj  Int
  deriving (Eq,Show)

data Type = TBool | TInt | TError | TString | TProg
  deriving (Eq, Show)

ex1 :: Stack
ex1 = [Right  "what", Left 1, Right "woo"]  

ex2 :: Prog
ex2 = [Randadj 2, Randnoun 4, Add]

ex4 = [PushI 0, IfElse [PushS "5", PushS "6", Add] [PushS "11"]]

ex5 = [Left 1, Left 2]


verblist = ["chase", "question", "reach", "kick", "yell"]
nounlist = ["car", "fire extinguisher", "ball", "pool", "tree", "house", "dog", "snake", "computer", "phone", "road", "light", "cave", "baby", "camper"]
adjectivelist = ["jumpy", "slimy", "moist", "cold", "hot", "bright", "hairy", "sticky", "loud", "colorful", "comfy", "soft", "hard", "lumpy", "long"]

sizeOfStack :: Stack -> Int
sizeOfStack []      = 0
sizeOfStack (x:xs)  = 1 + sizeOfStack xs

cmd :: Cmd -> Load
cmd Add         = \x -> case x of
                         (Right i : Right j : x') -> Just (Right (j ++ " " ++ i ) : x')
                         (Left i : Left j : x') -> Just (Left (j + i ) : x')
                         _ -> Nothing

cmd (PushS s) = \x -> Just (Right s : x)
cmd (PushI i) = \x -> Just (Left i : x)


cmd (Randverb y)   =  \x -> Just (Right  (randword verblist y) : x)

cmd (Randnoun y)   = \x ->  Just (Right  (randword nounlist y) : x)

cmd (Randadj y)   = \x ->  Just (Right  (randword adjectivelist y) : x)

cmd (IfElse s ss) = \x -> case x of
                        (Left 1 : x') -> prog s x'   --true
                        (Left 0 : x') -> prog ss x'  --false
                        _ -> Nothing



-- ex:   prog [While [PushI 24]] [Left 1, Left 1, Left 0, Left 1]

--Takes element before IFElse cmd on the stack and if its a 1(true) runs 's' else runs 'ss'
cmd (While s) = \x -> case x of
                      (Left 1 : x') -> case (prog s x') of
                                          Just xs -> prog [(While s)] (xs ++ (x'))
                                          _       -> Nothing
                      (Left 0 : x') -> Just x'
                      _             -> Just x


-- Typing Relation
typeOf :: Cmd -> Type
typeOf (PushS s)     = TString
typeOf (PushI i)     = TInt
typeOf Add           = TString
typeOf (Randverb y)  = TInt
typeOf (Randnoun y)  = TInt
typeOf (Randadj y)   = TInt
typeOf (IfElse s ss) = case (typeOf1 s, typeOf1 ss) of
                      (ts, tss) -> if ts == tss then ts else TError


typeOf1 :: [Cmd] -> Type
typeOf1 _        = TProg

randword :: [String] -> Int -> String
randword [] _ = " "
randword x y = x !! y

prog :: Prog -> Load
prog []       = \s -> Just s               -- when empty stack return stack
prog (c:p)    = \s -> case cmd c s of
                  Just s' -> prog p s'    --if cmd c s succeeds it returns a Just s', -> recursive call to rest of stack
                  _ -> Nothing

getBottom :: Stack -> Either Int String
getBottom [Left i] = Left i
getBottom [Right s] = Right s
getBottom (_:xs) = getBottom xs

-- Created an error or stack data type in order to create errors when there is an empty stack
data ErrorHandled = STK Stack | Error
  deriving(Eq,Show)

-- Pops the top element off the stack and deletes it
-- If the stack is empty return an Error
dropStack :: Stack -> ErrorHandled
dropStack [] = Error
dropStack (x : stack) = (STK stack)

swapStack :: Stack -> ErrorHandled
swapStack [] = Error
swapStack (a : b : stack) = (STK (b : a : stack))

dupStack :: Stack -> ErrorHandled
dupStack [] = Error
dupStack (x : stack) = (STK (x : x : stack))

swapDropStack :: Stack -> Int -> ErrorHandled
swapDropStack [] x = Error
swapDropStack (x : stack) y = (STK (stack !! y : stack))


run :: Prog -> Maybe Stack
run p = prog p []

-- Check if a list on the stack is a palindrome
-- return true if it is, return false if it is not
isPalindrome :: (Eq a) => [a] -> Bool
isPalindrome xs = f [] xs xs
  where
    f ss xs []              = ss == xs
    f ss (_:xs) [_]         = ss == xs
    f ss (x:xs) (_:_:es)    = f (x:ss) xs es
    


