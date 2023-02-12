# Regime Based Analysis using Gated Bayesian Network
**An implementation of Gated Bayesian Network for Basketball Team**

# Abstract :
In the dynamic sport of professional basketball, a team may encounter several tangible and intangible alterations over a period of time. Regime detection, a widely used method in the domain of financial market decision-making and medical treatment planning, may assist a team management personnel to gain insight into how a team is changing with time based on historical data. The similar study has been conducted by [( Bendtsen M., 2017)](https://link.springer.com/article/10.1007/s10618-017-0510-5) for the career trajectories of the baseball players . In this project, we have explored how multiple Bayesian networks could model the dynamics for a certain time frame. We have utilised basketball records starting from season 1983-84 to season 2020-21 for the NBA team Chicago Bulls. First, we identified the most important parameters to describe a team's performance using SHAP (\textbf{SH}apley \textbf{A}dditive ex\textbf{P}lanation) analysis.
Next, we identify the regimes based on the Metropolis-Hastings MCMC sampling of the posterior distribution of the dataset. After identifying the regimes in the dataset, we hypothesise different regime transition structures and identify the most optimal regime transition structure. Lastly, the optimal regime transition structure is used to create a Gated Bayesian network (GBN) and parameterise the GBN using Gaussian processes distribution. We discuss the limitations of this approach and our work. 
Our finding has been visualised along with historical evidence, which helps to provide insight into which parameter may be important for a certain period of history and its possible application for the team officials.

Keywords: probabilistic modelling, SHAP analysis, Shapley Values, Bayesian network, directed acyclic graphs, basketball analytics, gated Bayesian network, regime-based analysis, gaussian processes optimisation, hill climbing, NBA, Chicago Bulls



# Data :
Data courtesy of **Sports Reference LLC** under creative commons licence, [Basketball-Reference.com](https://www.basketball-reference.com/) -Basketball Statistics and History. 


# References :
1. Marcus Bendtsen. [“Regimes in baseball players’ career data.”](https://link.springer.com/article/10.1007/s10618-017-0510-5) In: Data Mining  Knowledge Discovery 31.6 (2017), pp. 1580–1621.ISSN:13845810.
