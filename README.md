# APS Modelagem Preditiva

Projeto analítico que aplica técnicas de modelagem preditiva para compreender padrões e antecipar comportamentos a partir de dados reais.  
O estudo envolve a construção, comparação e interpretação de diferentes modelos de **classificação** e **regressão**, buscando transformar dados em decisões com base estatística.

---

## Estrutura do Projeto

```
modelagem_preditiva/
│
├── data/                           # conjuntos de dados brutos e processados (⚠️ ignorados pelo Git)
├── code/                           # scripts de análise e modelagem
├── images/                         # gráficos, curvas ROC e outras visualizações
├── docs/                           # enunciado da APS e relatório final
├── .gitignore                      # arquivos e pastas ignorados no versionamento
├── README.md                       # visão geral do projeto
├── main.R                          # arquivo pai, que gere os exercícios contidos na pasta code
└── modelagem_preditiva.Rproj       # arquivo RStudio do projeto 

```

---

## Objetivos

- Desenvolver modelos preditivos aplicados a **cenários reais** (clientes e mercado automotivo);  
- Comparar o desempenho de algoritmos em termos de **acurácia**, **AUC** e **RMSE**;  
- Discutir a influência do **viés**, **variância** e **aleatorização** nos resultados;  
- Gerar **insights interpretáveis** para apoio à tomada de decisão.

---

## Execução do Projeto

O projeto pode ser executado no **VS Code** e **RStudio**.

### Passos iniciais

1. Clone este repositório:
```bash
   git clone https://github.com/gustavoribolla/modelagem_preditiva.git
   cd modelagem_preditiva
```

2. Abra no **VS Code** ou **RStudio**.

3. Instale as bibliotecas necessárias:

   ```r
   install.packages(c("tidyverse", "tree", "ranger", "pROC", "class", "catboost"))
   ```

4. Execute o script principal:

   ```r
   source("code/main.R")
   ```

5. As figuras geradas serão salvas automaticamente na pasta `images/`.

---

## Relatório

O relatório completo está disponível no Google Docs:
📄 [Acesse aqui](https://alinsperedu-my.sharepoint.com/:w:/g/personal/gustavocr2_al_insper_edu_br/ES2YJpYvL7BOj9zKbNkkS_MBnUZtruXpNpnpJ3LVVA7_EA?e=1Rf1pi)

> O relatório apresenta a fundamentação teórica, resultados experimentais, discussões e conclusões do projeto.

---

## Modelos Utilizados

* Regressão Logística
* Árvores de Classificação e Regressão
* Bagging e Random Forests
* k-NN (k-Nearest Neighbors)
* CatBoost

---

## Aplicações

* **Problema de churn:** previsão de cancelamento de clientes em uma instituição bancária.
* **Preço de automóveis usados:** estimativa de valor de mercado com base em atributos de veículos Mercedes.

---

## Conceitos-Chave Abordados

* Relação entre **viés** e **variância**
* Uso de **bootstrap** no bagging
* Aleatorização de splits em **Random Forests**
* Estimativa de erro **Out-of-Bag (OOB)**
* Comparação de **curvas ROC** e **AUC**

---

## Autor

**Gustavo Colombi Ribolla**<br>
Estudante de Ciência da Computação - Insper<br>
📫 [linkedin.com/in/gustavoribolla](https://linkedin.com/in/gustavoribolla)
