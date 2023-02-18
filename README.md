# Regime Based Analysis using Gated Bayesian Network
**An implementation of Gated Bayesian Network for Basketball Team**

# Abstract :
In the dynamic sport of professional basketball, a team may encounter several tangible and intangible alterations over a period of time. Regime detection, a widely used method in the domain of financial market decision-making and medical treatment planning, may assist a team management personnel to gain insight into how a team is changing with time based on historical data. The similar study has been conducted by [(Bendtsen M., 2017)](https://link.springer.com/article/10.1007/s10618-017-0510-5) for the career trajectories of the baseball players . In this project, we have explored how multiple Bayesian networks could model the dynamics for a certain time frame. We have utilised basketball records starting from season 1983-84 to season 2020-21 for the NBA team Chicago Bulls. First, we identified the most important parameters to describe a team's performance using SHAP (**SH**apley **A**dditive ex**P**lanation) analysis. Next, we identify the regimes based on the Metropolis-Hastings MCMC sampling of the posterior distribution of the dataset. After identifying the regimes in the dataset, we hypothesise different regime transition structures and identify the most optimal regime transition structure. Lastly, the optimal regime transition structure is used to create a Gated Bayesian network (GBN) and parameterise the GBN using Gaussian processes distribution. We discuss the limitations of this approach and our work.Our finding has been visualised along with historical evidence, which helps to provide insight into which parameter may be important for a certain period of history and its possible application for the team officials.

Keywords: probabilistic modelling, SHAP analysis, Shapley Values, Bayesian network, directed acyclic graphs, basketball analytics, gated Bayesian network, regime-based analysis, gaussian processes optimisation, hill climbing, NBA, Chicago Bulls

# Problem Statement :
The overall purpose of this Master Project is to explore the usage of the Gated Bayesian Network to evaluate the performance of a professional basketball team through history, which
could provide important insight into a team’s playing dynamics for the coach and other team strategists. The on-court combating quality of a basketball team could be measured from
many aspects. The apparent intention is to find out if we could use the gated-Bayesian network, which was used previously by [Bendtsen (2016)](https://link.springer.com/content/pdf/10.1007/s10618-017-0510-5.pdf) to assess the change of regimes of baseball players through their careers.

## Research Objectives :
The following three research objectives are thoroughly addressed in this degree project work.
We list the research objectives as follows,
1. Explore the essential features from the historical basketball data that significantly impact the team’s performance.
2. Scruitinse the applicability of the Gated Bayesian Network framework to the basketball data to learn the performance dynamics of a team.
3. Validate whether the aforementioned framework enhanced the understanding of a team’s dynamics using statistical measures and historical evidence.

## Scopes of the Master Project :
The scope of this Master Project is bound to scrutinise the performance statistics of the NBA team Chicago Bulls between the seasons 1983-84 to 2020-21. Furthermore, in this analysis,
each regular season, we consider that the individual team plays during 82 games, excluding the playoffs games. The reason for such a consideration is primarily because teams play
quite differently in the playoffs than in the regular season, so the same model would not be an apt choice. Additionally, the non-commercial data is utilised in this project available on the basketball-reference website at gratis. Lastly, the model described in this discourse is insensitive to the alteration in the NBA regulations over the decades.


# Data :
Data courtesy of **Sports Reference LLC** under creative commons licence, [Basketball-Reference](https://www.basketball-reference.com/) -Basketball Statistics and History. 
The dataset used in the experiment is composed of raw data and processed data as explained below:

|Term|Description|
| ----------- | ----------- |
|FG|Field Goal|
|FGA|Field Goal Attempts|
|FG%|Field Goal Percentage|
|3P|3 Point Goals|
|3PA|3 Points Goal Attempted|
|3P%|3 Points Goal Percentage|
|FT|Free Throw|
|FTA|Free Throw Attempts|
|FT%|Free Throw Percentage|
|ORB|Offensive Rebound|
|DRB|Defensive Rebound|
|TRB|Total Rebound|
|AST|Assist|
|STL|Steal|
|BLK|Block|
|TOV|Turnover|
|PF|Personal Fouls|
|ORtg|Offensive Ratings|
|DRtg|Defensive Ratings|
|Pace|Pace Factor|
|FTr|Free Throw Attempt Rate|
|3PAr|3-Points Attempt Rate|
|TS%|True Shooting Percentage|
|TRB%|Total Rebound Percentage|
|AST%|Assist Percentage|
|STL%|Steal Percentage|
|BLK%|Block Percentage|
|eFG%|Effective Field Goal Percentage|
|TOV%| Turnover Percentage|
|ORB%| Offensive Rebound Percentage|
|DRB%| Defensive Rebound Percentage|
|FT/FGA| Free Throw per Free Goal Attempt|
## Raw Data

|Type of Features| Features|
| ----------- | ----------- |
||Tm, Opp, FG, FGA, FG%, 3P, 3PA, 3P%, FT, FTA,|
|Regular BoxScore| FT%, ORB, DRB, TRB, AST, STL, BLK, TOV, PF|
||Tm, Opp, ORtg, DRtg, Pace, FTr, 3PAr|
||TS%, TRB%, AST%, STL%, BLK%|
|Advanced BoxScore |eFG%, TOV%, ORB%, FT/FGA (Offensive Four Factors)|
||eFG%, TOV%, DRB%, FT/FGA (Defensive Four Factors)|

## Trends in 3 Points Attempt with Time
 ![3PA](https://github.com/dimitramuni/GBN-Regime-in-Basketball/blob/main/results/misc/3PA_season.png)
 
## Heatmap for Chicago Bulls 
 ![Heatmap](https://github.com/dimitramuni/GBN-Regime-in-Basketball/blob/main/results/misc/chicago_heatmap.png)

# Key Findings : 

## SHAP Analysis 
![SHAP analysis](https://github.com/dimitramuni/GBN-Regime-in-Basketball/blob/main/results/shap/shap_analysis.png)

- Here the feature that has the highest effect on Team_Prospect is WinsInLast15,
i.e. the number of wins in the last fifteen games; this is unsurprising as the Team_Prospect
takes into account the running mean of score difference for the last twenty games, so there is
likely a higher correlation between these two events. 

- We observed a similar result for another feature WinsInLast10, which accounts for several wins in the last ten games, albeit the feature importance is less than that of WinsInLast15.

- The next three most important features are related to the player’s individual contribution. As described previously, the first category of the players are those who are going to continue playing in the next season; these players have a higher impact on the Team_Prospect than the contribution from the players who either have newly joined the team in the current season or the players from the current season who are going to be leaving the team in the
next season.
## Roster Continuity
- *Roster Continuity* measures the percentage of the current season roster made up of players from the previous season. In this figure, the roster continuity is plotted on the y-axis ranging between 0 to 1 (or 0% to 100%) along with the corresponding season on the x-axis. 
- The season where a team only played in the regular season is marked with grey coloured bars, and when the team is advancing to other levels, such as playing in Conference 1st Round, Conference Semi-Final, Conference Final or Championship Final represented by green, blue, turquoise and red colours accordingly. We can visually observe
that seasons, where Chicago Bulls had advanced to the Conference Semi-Final or above are described by blue, turquoise and red bars, which correspond to more than 50% roster continuity value (except for season 2010-11 for which roster continuity is 49%), which means that there is a significant correlation between roster stability of a team and team’s performance.
- Now, if we consider the stability of the roster in terms of players who continue to play in the next season, this would translate into the player’s contribution towards win share.
 ![Roster Continuity Chicago](https://github.com/dimitramuni/GBN-Regime-in-Basketball/blob/164d44504dd034ad62513b0086cfcd9feea95aeb/results/roster_continuity/chicago_roster_continuity.png)
 
## Gated bayesian Network for Chicago Bulls
 ![GBN](https://github.com/dimitramuni/GBN-Regime-in-Basketball/blob/main/diagrams/GBN.png)


# Ethical Consideration

- The data set utilised here is hosted on the website basketball-reference.com which seems to operate on a combination of ad revenue based *freemium* model, we have only accessed the available data without any cost.
- We have adhered to the [*Terms of Use*](https://www.sportsreference.com/termsofuse.htm) and [*Information Sharing*](https://www.sports-reference.com/sharing.html) guidelines laid out by the parent company of the data hosting website, Sports Reference LLC, to the best of our knowledge.
- Primarily, the data is utilised for academic research purposes. Furthermore, the research we conducted here is intended for constructive development in the sports analytics community (if any) without any commercial ambition.


# References :
1. Marcus Bendtsen. “Regimes in baseball players’ career data.” In: Data Mining Knowledge Discovery 31.6 (2016), pp. 1580–1621. ISSN:13845810.URL: https://link.springer.com/content/pdf/10.1007/s10618-017-0510-5.pdf.
2. Scott M Lundberg and Su-In Lee. “A unified approach to interpreting model predictions”. In: Advances in neural information processing systems 30 (2017).
3. Thomas Page. “Applications of wearable technology in elite sports”. In: i-manager’s Journal on Mobile Applications and Technologies 2.1 (2015), p.1.
4. Roland Lazenby and Olivier Bougard. Michael Jordan: The life. Talent sport, 2015.
5. Kerry Eggers. Jail blazers: How the Portland Trail Blazers became the bad boys of basketball Sports Publishing, 2021.
6. Jack McCallum. DREAM TEAM: How Michael, Magic, Larry, Charles and the Greatest Team of All Time Conquered the World and Changed the Game of Basketball Forever. Vol. 59. 7. Risk and Insurance Management Society, Inc., 2012, p. 43.
7. Matthew J. Barnes. “Alcohol: Impact on Sports Performance and Recovery in Male Athletes”. In: Sports Medicine 44.7 (2014), pp. 909–919. DOI: 10.1007/s40279-014 -0192-8. URL: https://doi.org/10.1007/s40279-014-0192-8.
8. Zsuzsanna Dömötör, Roberto Ruíz-Barquín, and Attila Szabo. “Superstitious behavior in sport: A literature review”. In: Scandinavian Journal of Psychology 57.4 (2016), pp. 368–382. DOI:https://doi.org/10.1111/sjop.12301.
9. Masaru Teramoto and Chad L. Cross. “Relative Importance of Performance Factors in Winning NBA Games in Regular Season versus Playoffs”. In: Journal of Quantitative Analysis in Sports 6.3 (2010). DOI: doi:10.2202/1559- 0410.1260. URL: https://doi.org/10.2202/1559-0410.1260.
10. Elia Morgulev and Yair Galily. “Choking or Delivering Under Pressure? The Case of Elimination Games in NBA Playoffs”. In: Frontiers in Psychology 9 (2018), p. 979. ISSN: 1664-1078. DOI:10.3389/fpsyg.2018.00979. URL:https ://www.frontiersin.org/article/10.3389/fpsyg.2018.00979.
11. LLOYD S Shapley. Quota solutions of n-person games. Tech. rep. RAND CORP SANTA MONICA CA, 1952.
12. Christoph Molnar. Interpretable Machine Learning. A Guide for Making Black Box Models Explainable. 2nd ed. 2022. URL: https://christophm.github.io/interpretable-ml-book.
13. Erik Štrumbelj and Igor Kononenko. “Explaining prediction models and individual predictions with feature contributions”. In: Knowledge and information systems 41.3 (2014), pp. 647–665.
14. Scott M. Lundberg, Gabriel G. Erion, and Su-In Lee. “Consistent Individualized Feature Attribution for Tree Ensembles”. In: CoRR abs/1802.03888 (2018).URL: http://arxiv.org/abs/1802.03888.
15. Andrew Gelman, John B. Carlin, Hal S. Stern, and Donald B. Rubin. Bayesian data analysis. 3rd ed. Statistics texts. Chapman Hall, 1995. ISBN: 9781439840955. URL:http://www.stat.columbia.edu/~gelman/book/BDA3.pdf.
16. Thomas Bayes. “LII. An essay towards solving a problem in the doctrine of chances. By the late Rev. Mr. Bayes, FRS communicated by Mr. Price, in a letter to John Canton, AMFR S”. In: Philosophical transactions of the Royal Society of London 53 (1763), pp. 370–418.
17. William M Bolstad and James M Curran. Introduction to Bayesian statistics. John Wiley & Sons, 2016.
18. Bradley Efron. “Bayes’ Theorem in the 21st Century”. In: Science 340.6137 (2013), pp. 1177–1178. DOI: 10.1126/science.1236536. eprint: https://www.science.org/doi/pdf/10.1126/science.1236536. URL:https://www.science.org/doi/abs/10.1126/science.1236536.
19. Leland Gerson Neuberg. “Causality: models, reasoning, and inference, by judea pearl, cambridge university press, 2000”. In: Econometric Theory 19.4 (2003), pp. 675–685.
20. Marco Scutari, Catharina Elisabeth Graafland, and José Manuel Gutiérrez. “Who learns better Bayesian network structures: Accuracy and speed of structure learning algorithms”. In: International Journal of Approximate Reasoning 115 (2019), pp. 235–253.ISSN: 0888-613X. DOI:https://doi.org/10.1016/j.ijar.2019.10.003. 
21. David Heckerman, Dan Geiger, and David M Chickering. “Learning Bayesian networks: The combination of knowledge and statistical data”. In: Machine learning 20.3 (1995), pp. 197–243.
22. Marco Scutari. “Learning Bayesian Networks with the bnlearn R Package”. In: Journal of Statistical Software 35.3 (2010), pp. 1–22. DOI: 10.18637/jss.v035.i03. URL: https://www.jstatsoft.org/index.php/jss/article/view/v035i03.
23. David Heckerman. “A Tutorial on Learning with Bayesian Networks”. In: Innovations in Bayesian Networks: Theory and Applications. Ed. by Dawn E. Holmes and Lakhmi C. Jain. Berlin, Heidelberg: Springer Berlin Heidelberg, 2008, pp. 33–82. ISBN: 978-3-540-85066-3. DOI: 10.1007/978- 3- 540- 85066- 3_3. URL: https://doi.org/10.1007/978-3-540-85066-3_3.
24. Ioannis Tsamardinos, Laura E Brown, and Constantin F Aliferis. “The max-min hill climbing Bayesian network structure learning algorithm”. In: Machine learning 65.1(2006), pp. 31–78.
25. Herbert S. Wilf. “Chapter 1 - Introductory Ideas and Examples”. In: Generatingfunctionology. Ed. by Herbert S. Wilf. Academic Press, 1990, pp. 1–26. ISBN: 978-0-12-751955-5. DOI: https ://doi.org/10.1016/ B978-0-12-751955-5.50004-6. URL: https://www.sciencedirect.com/science/article/pii/B9780127519555500046.
26. Marcus Bendtsen and Jose M Peña. “Gated Bayesian Networks”. In: Twelfth Scandinavian Conference on Artificial Intelligence: SCAI 2013. Vol. 257. IOS Press. 2013, p. 35.
27. Marcus Bendtsen and Jose M. Peña. “Gated Bayesian networks for algorithmic trading.” In: International Journal of Approximate Reasoning 69 (2016), pp. 58–80. ISSN: 0888-613X.
28. Stéphane Alarie, Charles Audet, Aımen E Gheribi, Michael Kokkolaras, and Sébastien Le Digabel. “Two decades of blackbox optimization applications”. In: EURO Journal on Computational Optimization 9 (2021), p. 100011.
29. Christopher KI Williams and Carl Edward Rasmussen. Gaussian processes for machine learning. Vol. 2. 3. MIT press Cambridge, MA, 2006.
30. Kilian Weinberger. "Lecture 15: Gaussian Processes". https://www.cs.cornell.edu/courses/cs4780/2018fa/lectures/lecturenote15. html. Accessed:2022-11-11. 2018.
31. E Brochu, V Cora, and N de Freitas. A Tutorial on Bayesian Optimization of Expensive Cost Functions‚ with Application to Active User Modeling and Hierarchical Reinforcement Learning. Tech. rep. 2009. URL: https://ora.ox.ac.uk/objects/uuid:9e6c9666-5641-4924-b9e7-4b768a96f50b.
32. NBA Media Ventures LLC. NBA Rulebook 2019-20. 2020. URL: https://official.nba.com/rulebook/.
33. Paola Zuccolotto, Marica Manisera, and Marco Sandri. “Alley-oop! Basketball analytics
in R”. In: Significance 18.2 (2021), pp.26–31.URL:https://rss.onlinelibrary.wiley.com/doi/abs/10.1111/1740-9713.01507.
34. Melanie J Formentin. “Crisis Communication and the NBA Lockout: Exploring Fan Reactions to Crisis Response Strategies in Sport”. In: Reputational Challenges in Sport.Routledge, 2018, pp. 117–134.
35. González Dos Santos Teno, Chunyan Wang, Niklas Carlsson, and Patrick Lambrix. “Predicting Season Outcomes for the NBA”. In: Machine Learning and Data Mining for Sports Analytics. Ed. by Ulf Brefeld, Jesse Davis, Jan Van Haaren, and Albrecht Zimmermann. Cham: Springer International Publishing, 2022, pp. 129–142. ISBN: 978-3-031-02044-5.
36. Thomas Huyghe, Aaron T Scanlan, Vincent J Dalbo, and Julio Calleja-González. “The negative influence of air travel on health and performance in the national basketball association: a narrative review”. In: Sports 6.3 (2018), p. 89.
37. Dean Oliver. Basketball on paper: rules and tools for performance analysis. Potomac Books, Inc., 2004.
38. Jeremy Arkes and Jose Martinez. “Finally, Evidence for a Momentum Effect in the NBA”. In: Journal of Quantitative Analysis in Sports 7.3 (2011). DOI: doi :10.2202/1559-0410.1304. URL: https://doi.org/10.2202/1559-0410.1304.
39. Sports Reference LLC. Basketball-Reference.com - Basketball Statistics and History. 2021. URL: https://www.basketball-reference.com/.
40. V.I. Rodionov. “On the number of labeled acyclic digraphs”. In: Discrete Mathematics 105.1 (1992), pp. 319–321. ISSN: 0012-365X. URL: https://www.sciencedirect.com/science/article/pii/0012365X92901559.
41. Thomas M Wagner, Alexander Benlian, and Thomas Hess. “Converting freemium customers from free to premium—the role of the perceived premium fit in the case of music as a service”. In: Electronic Markets 24.4 (2014), pp. 259–268.
42. James Cussens and Mark Bartlett. GOBNILP: Globally Optimal Bayesian Network learning using Integer Linear Programming. English. 2013.
43. Mauro Scanagatta, Antonio Salmerón, and Fabio Stella. “A survey on Bayesian network structure learning from data”. In: Progress in Artificial Intelligence 8.4 (2019), pp. 425–439.

