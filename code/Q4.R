# Q4 - OOB RMSE x Test RMSE (California housing)

set.seed(42)
suppressPackageStartupMessages(library(ranger))

# --- carregar dados ---
paths <- c("data/california.csv")
path <- paths[file.exists(paths)]
df <- read.csv(path[1], stringsAsFactors = TRUE)

target <- "median_house_value"

# remover linhas com NA (simples e explicável)
df <- df[complete.cases(df), , drop = FALSE]

# --- split 50/50 ---
n  <- nrow(df)
id <- sample.int(n, floor(0.5*n))
train <- df[id, , drop = FALSE]
test  <- df[-id, , drop = FALSE]
y_test <- test[[target]]

# garantir níveis iguais do fator
if (is.factor(train$ocean_proximity)) {
  test$ocean_proximity <- factor(test$ocean_proximity,
                                 levels = levels(train$ocean_proximity))
}

form <- as.formula(paste(target, "~ ."))
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2))

# --- sequência de árvores ---
ntree_seq <- seq(10L, 500L, by = 10L)

# mtry explícito (p/3) — regressão
p <- ncol(train) - 1
mtry_fix <- max(2, floor(p/3))

oob_rmse  <- numeric(length(ntree_seq))
test_rmse <- numeric(length(ntree_seq))

for (i in seq_along(ntree_seq)) {
  nt <- ntree_seq[i]
  fit <- ranger(
    formula = form,
    data = train,
    num.trees = nt,
    mtry = mtry_fix,
    oob.error = TRUE,   # MSE OOB em $prediction.error
    seed = 42
  )
  oob_rmse[i]  <- sqrt(fit$prediction.error)                  # OOB MSE -> RMSE
  preds        <- predict(fit, data = test)$predictions
  test_rmse[i] <- rmse(y_test, preds)                         # RMSE de teste
}

# diferença entre curvas
delta <- abs(oob_rmse - test_rmse)
rel   <- 100 * delta / test_rmse
cat(sprintf("Em B=%d: OOB=%.1f | Test=%.1f | Diferença=%.1f (%.2f%%)\n",
            tail(ntree_seq,1), tail(oob_rmse,1), tail(test_rmse,1),
            tail(delta,1), tail(rel,1)))


# --- gráfico OOB vs Teste ---
if (!dir.exists("images")) dir.create("images", recursive = TRUE)
png("images/Q4_OOB_vs_Test.png", width = 1200, height = 800, res = 120)
plot(ntree_seq, oob_rmse, type = "l", lwd = 2,
     xlab = "Número de árvores (B)", ylab = "RMSE",
     main = "California Housing — OOB RMSE vs Test RMSE (ranger)")
lines(ntree_seq, test_rmse, lwd = 2, lty = 2)
legend("topright", legend = c("OOB RMSE", "Teste RMSE"),
       lty = c(1, 2), lwd = 2, bty = "n")
dev.off()

cat(sprintf("B=%d | OOB_RMSE=%.5f | Test_RMSE=%.5f\n",
            tail(ntree_seq, 1), tail(oob_rmse, 1), tail(test_rmse, 1)))
