--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid (mappend)
import Hakyll

githubPagesConfig :: Configuration
githubPagesConfig =
  defaultConfiguration
    { destinationDirectory = "docs"
    }

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith githubPagesConfig $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

  match "assets/*" $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match "src/*.md" $ do
    compile pandocCompiler

  match "src/*.html" $ do
    compile getResourceBody

  match "index.html" $ do
    route idRoute
    compile templateBodyCompiler
    compile $ do
      a <- loadBody "src/about-profile.html"
      b <- loadBody "src/about-bio.md"
      c <- loadBody "src/news.md"
      d <- loadBody "src/misc.md"
      getResourceBody
        >>= applyAsTemplate
          ( indexContext
              [ (a, "about-profile"),
                (b, "about-bio"),
                (c, "news"),
                (d, "misc")
              ]
          )
        >>= relativizeUrls

indexContext :: [(String, String)] -> Context String
indexContext bodyAndNames =
  let (bodies, names) = unzip bodyAndNames
      fields = mconcat $ zipWith constField names bodies
   in fields `mappend` defaultContext
