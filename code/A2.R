# A2 - Preço de automóveis usados (regressão)

set.seed(42)
suppressPackageStartupMessages({
  library(tree)
  library(ranger)
})

# Pastas necessárias
for (d in c("images/A2", "results")) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# Helper para localizar o CSV
find_file <- function(fname) {
  cand <- c(file.path("data", fname),
            fname,
            file.path("..", "data", fname))
  hit <- cand[file.exists(cand)]
  if (!length(hit)) stop(sprintf("Arquivo '%s' não encontrado. Coloque-o em 'data/'. WD=%s", fname, getwd()))
  hit[1]
}

# Ler dados + checagem mínima
path <- find_file("used_cars.csv")
cars <- read.csv(path, stringsAsFactors = TRUE)

if (!"price" %in% names(cars)) {
  stop("A coluna 'price' (alvo) não foi encontrada em used_cars.csv.")
}
# Garantir que price é numérico
if (!is.numeric(cars$price)) {
  suppressWarnings({
    cars$price <- as.numeric(as.character(cars$price))
  })
  if (anyNA(cars$price)) stop("A coluna 'price' não pôde ser convertida para numérica sem NAs.")
}

# Split 50/50 e alinhar níveis fator no teste
split_id <- sample(seq_len(nrow(cars)), floor(0.5*nrow(cars)))
tr <- cars[split_id, , drop = FALSE]
te <- cars[-split_id, , drop = FALSE]
for (cn in names(tr)) {
  if (is.factor(tr[[cn]])) {
    te[[cn]] <- factor(as.character(te[[cn]]), levels = levels(tr[[cn]]))
  }
}

y_test <- te$price
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2))

# Regressão Linear
m_lin <- lm(price ~ ., data = tr)
p_lin <- predict(m_lin, te)
rmse_lin <- rmse(y_test, p_lin)
png("images/A2/A2_pred_vs_obs_linear.png", 1200, 800, res = 120)
plot(y_test, p_lin, pch = 16, cex = 0.7,
     xlab = "Preço observado (teste)", ylab = "Preço previsto",
     main = sprintf("Previsto vs Observado — Regressão Linear (RMSE=%.2f)", rmse_lin))
abline(0,1,lty=2); dev.off()

# Árvore de Regressão
m_tree <- tree(price ~ ., data = tr)
p_tree <- predict(m_tree, te)
rmse_tree <- rmse(y_test, p_tree)
png("images/A2/A2_pred_vs_obs_tree.png", 1200, 800, res = 120)
plot(y_test, p_tree, pch = 16, cex = 0.7,
     xlab = "Preço observado (teste)", ylab = "Preço previsto",
     main = sprintf("Previsto vs Observado — Árvore (RMSE=%.2f)", rmse_tree))
abline(0,1,lty=2); dev.off()

# Random Forest
m_rf <- ranger(price ~ ., data = tr, num.trees = 500, seed = 42)
p_rf <- predict(m_rf, te)$predictions
rmse_rf <- rmse(y_test, p_rf)
png("images/A2/A2_pred_vs_obs_rf.png", 1200, 800, res = 120)
plot(y_test, p_rf, pch = 16, cex = 0.7,
     xlab = "Preço observado (teste)", ylab = "Preço previsto",
     main = sprintf("Previsto vs Observado — Random Forest (RMSE=%.2f)", rmse_rf))
abline(0,1,lty=2); dev.off()

# CatBoost
has_cb <- requireNamespace("catboost", quietly = TRUE)
if (has_cb) {
  library(catboost)
  # One-hot consistente
  mm_all <- model.matrix(price ~ ., data = rbind(tr, te))
  mm_tr  <- mm_all[seq_len(nrow(tr)), -1, drop = FALSE]
  mm_te  <- mm_all[-seq_len(nrow(tr)), -1, drop = FALSE]

  pool_tr <- catboost.load_pool(mm_tr, label = tr$price)
  pool_te <- catboost.load_pool(mm_te)

  m_cb <- catboost.train(
    pool_tr, NULL,
    params = list(
      loss_function = "RMSE",
      iterations = 300, depth = 6, learning_rate = 0.1,
      random_seed = 42, verbose = 0
    )
  )
  p_cb <- catboost.predict(m_cb, pool_te)
  rmse_cb <- rmse(y_test, p_cb)

  png("images/A2/A2_pred_vs_obs_catboost.png", 1200, 800, res = 120)
  plot(y_test, p_cb, pch = 16, cex = 0.7,
       xlab = "Preço observado (teste)", ylab = "Preço previsto",
       main = sprintf("Previsto vs Observado — CatBoost (RMSE=%.2f)", rmse_cb))
  abline(0,1,lty=2); dev.off()
} else {
  message("CatBoost não instalado — pulando esse modelo.")
}

# Tabela alinhada (console + CSV)
vals <- c(Linear = rmse_lin, Árvore = rmse_tree, RandomForest = rmse_rf)
if (exists("rmse_cb")) vals <- c(vals, CatBoost = rmse_cb)

res <- data.frame(
  Modelo = names(vals),
  RMSE   = sprintf("%.2f", as.numeric(vals)),
  check.names = FALSE
)

print(res, row.names = FALSE)
write.csv(res, "results/A2_resultados.csv", row.names = FALSE)