library(httr2)
library(purrr)
library(dplyr)

# ── Configuration ──────────────────────────────────────────────────────────────

BASE_URL       <- "https://api.nb.no/catalog/v1/items"
CAMPAIGN_TERMS <- c("valgkamp", "dørbanking", "stands", "valgstand", "besøk", "kampanje")
FROM_DATE      <- "20230601"
TO_DATE        <- "20230911"   # election day

# ── Locations ──────────────────────────────────────────────────────────────────

locations <- tibble(
  neighborhood = c("Grünerløkka", "Sagene", "Frogner", "Gamle Oslo", "Østensjø"),
  municipality = "Oslo"
)

# ── Core search function ───────────────────────────────────────────────────────

search_articles <- function(neighborhood, municipality,
                            from_date = FROM_DATE, to_date = TO_DATE,
                            n_results = 50) {
  query <- sprintf(
    '"%s" "%s" (%s)',
    neighborhood,
    municipality,
    paste(CAMPAIGN_TERMS, collapse = " OR ")
  )

  resp <- request(BASE_URL) |>
    req_url_query(
      q         = query,
      mediatype = "aviser",
      fromDate  = from_date,
      toDate    = to_date,
      size      = n_results
    ) |>
    req_retry(max_tries = 3, backoff = ~ 2) |>
    req_throttle(rate = 2) |>
    req_error(is_error = \(r) FALSE) |>
    req_perform()

  if (resp_status(resp) != 200) {
    warning(sprintf("HTTP %d for '%s'", resp_status(resp), neighborhood))
    return(NULL)
  }

  body      <- resp_body_json(resp)
  n_hits    <- body[["page"]][["totalElements"]] %||% NA_integer_
  items     <- body[["_embedded"]][["items"]]

  if (is.null(items) || length(items) == 0) {
    return(tibble(
      neighborhood = neighborhood,
      municipality = municipality,
      n_hits       = n_hits,
      date         = NA_character_,
      title        = NA_character_,
      snippet      = NA_character_
    ))
  }

  map(items, function(item) {
    title     <- item[["metadata"]][["title"]] %||% NA_character_
    date      <- item[["metadata"]][["originInfo"]][["issued"]] %||% NA_character_
    highlights <- item[["highlight"]][["fulltext"]]
    snippet   <- if (!is.null(highlights) && length(highlights) > 0)
                   highlights[[1]]
                 else
                   NA_character_

    tibble(
      neighborhood = neighborhood,
      municipality = municipality,
      n_hits       = n_hits,
      date         = date,
      title        = title,
      snippet      = snippet
    )
  }) |>
    bind_rows()
}

# ── Inspect raw response for one location (run first to check field names) ─────

inspect_raw <- function(neighborhood, municipality) {
  query <- sprintf(
    '"%s" "%s" (%s)',
    neighborhood,
    municipality,
    paste(CAMPAIGN_TERMS, collapse = " OR ")
  )
  request(BASE_URL) |>
    req_url_query(q = query, mediatype = "aviser",
                  fromDate = FROM_DATE, toDate = TO_DATE, size = 1) |>
    req_perform() |>
    resp_body_json()
}

# ── Run over all locations ─────────────────────────────────────────────────────

results <- map2(
  locations$neighborhood,
  locations$municipality,
  \(n, m) {
    message("Querying: ", n, ", ", m)
    search_articles(n, m)
  }
) |>
  bind_rows()

# ── Summary: one row per neighborhood with hit count ──────────────────────────

hit_counts <- results |>
  distinct(neighborhood, municipality, n_hits)

# ── Vectors ───────────────────────────────────────────────────────────────────

snippets <- results$snippet
hits     <- setNames(hit_counts$n_hits, hit_counts$neighborhood)
