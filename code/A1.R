# A1 - Churn (classificação)

set.seed(42)
suppressPackageStartupMessages({
  library(class)   # k-NN
  library(tree)    # Árvore de classificação
  library(ranger)  # Random Forest
  library(pROC)    # ROC/AUC
})

# Dados
paths <- c("data/churn.csv", "churn.csv", "../data/churn.csv")
path  <- paths[file.exists(paths)]
if (!length(path)) stop(sprintf("Não achei churn.csv. WD=%s", getwd()))
churn <- read.csv(path[1], stringsAsFactors = TRUE)

# Alvo binário
churn$Exited <- factor(churn$Exited, levels = c("No","Yes"))

# Split 50/50
id  <- sample(seq_len(nrow(churn)), floor(0.5*nrow(churn)))
tr  <- churn[id, , drop = FALSE]
te  <- churn[-id, , drop = FALSE]
ytr <- tr$Exited
yte <- te$Exited
yte01 <- as.integer(yte == "Yes")

# Matriz numérica (mesmas colunas) p/ kNN e CatBoost
mm_all <- model.matrix(Exited ~ ., data = rbind(tr, te))
mm_tr  <- mm_all[seq_len(nrow(tr)), -1, drop = FALSE]
mm_te  <- mm_all[-seq_len(nrow(tr)), -1, drop = FALSE]

# Padronização para kNN (usar estatísticas do treino)
Xtr <- scale(mm_tr)
Xte <- scale(mm_te, center = attr(Xtr, "scaled:center"),
                    scale  = attr(Xtr, "scaled:scale"))

# Helpers
acc  <- c(); aucv <- c(); rocs <- list()
rm.acc <- function(pred, truth) mean(pred == truth)

# k-NN (k = sqrt(n_train), ímpar)
k <- round(sqrt(nrow(Xtr))); if (k %% 2 == 0) k <- k + 1
pred_knn <- knn(train = Xtr, test = Xte, cl = ytr, k = k, prob = TRUE)
p_knn <- ifelse(pred_knn == "Yes", attr(pred_knn, "prob"), 1 - attr(pred_knn, "prob"))
acc["kNN"] <- rm.acc(pred_knn, yte)
rocs[["kNN"]] <- roc(yte01, p_knn, quiet = TRUE)
aucv["kNN"] <- as.numeric(auc(rocs[["kNN"]]))

# Regressão Logística
m_log <- glm(Exited ~ ., data = tr, family = binomial())
p_log <- predict(m_log, te, type = "response")
pred_log <- factor(ifelse(p_log >= 0.5, "Yes", "No"), levels = c("No","Yes"))
acc["Logistic"] <- rm.acc(pred_log, yte)
rocs[["Logistic"]] <- roc(yte01, p_log, quiet = TRUE)
aucv["Logistic"] <- as.numeric(auc(rocs[["Logistic"]]))

# Árvore de Classificação (tree)
m_tree <- tree(Exited ~ ., data = tr)
p_tree <- predict(m_tree, te, type = "vector")[, "Yes"]   # prob da classe "Yes"
pred_tree <- factor(ifelse(p_tree >= 0.5, "Yes", "No"), levels = c("No","Yes"))
acc["Tree"] <- rm.acc(pred_tree, yte)
rocs[["Tree"]] <- roc(yte01, p_tree, quiet = TRUE)
aucv["Tree"] <- as.numeric(auc(rocs[["Tree"]]))

# Random Forest (ranger)
m_rf <- ranger(Exited ~ ., data = tr, probability = TRUE, num.trees = 500, seed = 42)
p_rf <- predict(m_rf, te)$predictions[, "Yes"]
pred_rf <- factor(ifelse(p_rf >= 0.5, "Yes", "No"), levels = c("No","Yes"))
acc["RandomForest"] <- rm.acc(pred_rf, yte)
rocs[["RandomForest"]] <- roc(yte01, p_rf, quiet = TRUE)
aucv["RandomForest"] <- as.numeric(auc(rocs[["RandomForest"]]))

# CatBoost (deixei opcional para quando não tinha conseguido instalar)
has_cb <- requireNamespace("catboost", quietly = TRUE)
if (has_cb) {
  library(catboost)

  # Rótulo binário sem NA
  tr_cb <- droplevels(tr[!is.na(tr$Exited), , drop = FALSE])
  te_cb <- droplevels(te[!is.na(te$Exited), , drop = FALSE])
  ytr01 <- as.integer(tr_cb$Exited == "Yes")

  # one-hot consistente p/ o subconjunto (garante mesmas colunas)
  mm_all_cb <- model.matrix(Exited ~ ., data = rbind(tr_cb, te_cb))
  mm_tr_cb  <- mm_all_cb[seq_len(nrow(tr_cb)), -1, drop = FALSE]
  mm_te_cb  <- mm_all_cb[-seq_len(nrow(tr_cb)), -1, drop = FALSE]

  pool_tr <- catboost.load_pool(mm_tr_cb, label = ytr01)
  pool_te <- catboost.load_pool(mm_te_cb)

  m_cb <- catboost.train(
    pool_tr, NULL,
    params = list(loss_function = "Logloss",
                  iterations = 300, depth = 6, learning_rate = 0.1,
                  random_seed = 42, verbose = 0)
  )
  p_cb <- catboost.predict(m_cb, pool_te, prediction_type = "Probability")
  pred_cb <- factor(ifelse(p_cb >= 0.5, "Yes", "No"), levels = c("No","Yes"))

  acc["CatBoost"] <- rm.acc(pred_cb, te_cb$Exited)
  rocs[["CatBoost"]] <- roc(as.integer(te_cb$Exited == "Yes"), p_cb, quiet = TRUE)
  aucv["CatBoost"] <- as.numeric(auc(rocs[["CatBoost"]]))
} else {
  message("CatBoost não instalado — pulando esse modelo.")
}

# Tabela alinhada (console + CSV)
pref <- c("kNN","Logistic","Tree","RandomForest","CatBoost")
models <- intersect(pref, unique(c(names(acc), names(aucv))))

res <- data.frame(
  Modelo   = models,
  Acuracia = sprintf("%.4f", acc[models]),
  AUC      = sprintf("%.4f", aucv[models]),
  check.names = FALSE
)

print(res, row.names = FALSE)
if (!dir.exists("results")) dir.create("results", recursive = TRUE)
write.csv(res, "results/A1_resultados.csv", row.names = FALSE)

# ROC de todos
png("images/A1/A1_ROC_all.png", width = 1200, height = 800, res = 120)
nm <- names(rocs)
plot(rocs[[nm[1]]], main = "Churn — ROC (todos os modelos)")
if (length(nm) >= 2) for (i in 2:length(nm)) plot(rocs[[nm[i]]], add = TRUE, lty = i)
legend("bottomright",
       legend = paste0(names(aucv), " (AUC=", sprintf("%.3f", aucv), ")"),
       lty = 1:length(nm), bty = "n")
dev.off()
