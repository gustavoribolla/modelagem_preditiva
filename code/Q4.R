# Q4 - OOB RMSE x Test RMSE (California housing)

set.seed(42)
suppressPackageStartupMessages(library(ranger))

# Pastas necessárias
for (d in c("images/Q4", "results")) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# Helper para localizar o CSV
find_file <- function(fname) {
  cand <- c(file.path("data", fname), fname, file.path("..", "data", fname))
  hit  <- cand[file.exists(cand)]
  if (!length(hit)) stop(sprintf("Arquivo '%s' não encontrado. Coloque-o em 'data/'. WD=%s", fname, getwd()))
  hit[1]
}

# Carregar dados + checagem de colunas
path <- find_file("california.csv")
df <- read.csv(path, stringsAsFactors = TRUE)

required <- c("longitude","latitude","housing_median_age","total_rooms","total_bedrooms",
              "population","households","median_income","median_house_value","ocean_proximity")
miss <- setdiff(required, names(df))
if (length(miss)) stop(sprintf("Colunas faltando no dataset: %s", paste(miss, collapse = ", ")))

target <- "median_house_value"

# Remover linhas com NA (simples e explicável)
df <- df[complete.cases(df), , drop = FALSE]

# Split 50/50
n  <- nrow(df)
id <- sample.int(n, floor(0.5*n))
train <- df[id, , drop = FALSE]
test  <- df[-id, , drop = FALSE]
y_test <- test[[target]]

# Garantir níveis iguais do fator (se existir no treino)
if (is.factor(train$ocean_proximity)) {
  test$ocean_proximity <- factor(test$ocean_proximity, levels = levels(train$ocean_proximity))
}

form <- as.formula(paste(target, "~ ."))
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2))

# Sequência de árvores
ntree_seq <- seq(10L, 500L, by = 10L)

# Mtry explícito (≈ p/3) - regressão
p <- ncol(train) - 1
mtry_fix <- max(2, floor(p/3))

oob_rmse  <- numeric(length(ntree_seq))
test_rmse <- numeric(length(ntree_seq))

for (i in seq_along(ntree_seq)) {
  nt <- ntree_seq[i]
  fit <- ranger(
    formula   = form,
    data      = train,
    num.trees = nt,
    mtry      = mtry_fix,
    oob.error = TRUE,
    seed      = 42
  )
  oob_rmse[i]  <- sqrt(fit$prediction.error)
  preds        <- predict(fit, data = test)$predictions
  test_rmse[i] <- rmse(y_test, preds)
}

# Diferenças (absoluta e relativa)
delta <- abs(oob_rmse - test_rmse)
rel   <- 100 * delta / test_rmse

cat(sprintf("Em B=%d: OOB=%.2f | Test=%.2f | Dif.=%.2f (%.2f%%)\n",
            tail(ntree_seq,1), tail(oob_rmse,1), tail(test_rmse,1),
            tail(delta,1), tail(rel,1)))

# Gráfico OOB vs Teste
png("images/Q4/Q4_OOB_vs_Test.png", width = 1200, height = 800, res = 120)
plot(ntree_seq, oob_rmse, type = "l", lwd = 2,
     xlab = "Número de árvores (B)", ylab = "RMSE",
     main = "California Housing — OOB RMSE vs Test RMSE (ranger)")
lines(ntree_seq, test_rmse, lwd = 2, lty = 2)
legend("topright", legend = c("OOB RMSE", "Teste RMSE"),
       lty = c(1, 2), lwd = 2, bty = "n")
dev.off()

# Salvar tabela com as curvas
tab <- data.frame(
  num_trees = ntree_seq,
  oob_rmse  = oob_rmse,
  test_rmse = test_rmse,
  diff_abs  = delta,
  diff_rel_pct = rel
)
write.csv(tab, "results/Q4_oob_vs_test.csv", row.names = FALSE)

cat(sprintf("B=%d | OOB_RMSE=%.5f | Test_RMSE=%.5f\n",
            tail(ntree_seq, 1), tail(oob_rmse, 1), tail(test_rmse, 1)))
