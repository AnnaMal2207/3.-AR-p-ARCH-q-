#Лабораторная работа: AR(p)ARCH(q) и реальные данные
#Реализовать 𝐴𝑅(2)𝐴𝑅𝐶𝐻(3) процесс из 𝑛 = 2100 наблюдений с значениями параметров 𝜃 = (−0.3, 0.4)′, 𝐴 = (1, 0.2, 0.1, 0.2)′ и построить его график.
#library(stats)
set.seed(123)
library("tseries")
n = 2100
n_2 = 2000
n_3 = 100
Teta = c(-0.3, 0.4)
A = c(1, 0.2, 0.1, 0.2)
#par(mfrow = c(2, 1))
#ar_2 = arima.sim(n=2100, list(order=c(2,0,0), ar=Teta))
#plot(ar_2, type='l', main = "график стационарного процесса AR(2)ARCH(3)")

AR2_CH3 = function(n,a,Teta,ret)
{x = array(dim = n)
 s = array(dim = n)
 E = rnorm(n,0,1)
 s[1]=A[1]
 x[1]=sqrt(s[1])*E[1] 
 s[2]=A[1]+A[2]*x[1]^2
 x[2]=sqrt(s[2])*E[2]+Teta[1]*x[1]
 s[3]=A[1]+A[2]*x[2]^2+ A[3]*x[1]^2 
 x[3]=sqrt(s[3])*E[3]+Teta[1]*x[2]+Teta[2]*x[1]
   
 for (i in 4:n) 
   {s[i] = a[1] + a[2]*x[i-1]^2 + a[3]*x[i-2]^2 + a[4]*x[i-3]^2
    x[i] = Teta[1]*x[i-1]+Teta[2]*x[i-2] + sqrt(s[i])*E[i]}
 if (ret==1) return(x) else return(sqrt(s))
}
AR_2 = AR2_CH3(n,A,Teta,1)
plot(AR_2, type = 'l', col = 'purple', main = "график стационарного процесса AR(2)ARCH(3)")

#Разделить, полученную на первом шаге последовательность {𝑥𝑛}, в отношении 20:1 на обучающую и тестовую выборки
x_ob = AR_2[1 : n_2] 
x_test = AR_2[(n_2 + 1) : n]
ar_model = arima(x_ob, order = c(2, 0, 0), include.mean = FALSE)
Teta_1 = c(ar_model$coef[1], ar_model$coef[2])
h = array(dim = n_2)
h[1] = x_ob[1]
h[2] = x_ob[2] - Teta_1[1]*x_ob[1]
for (i in 3 : n_2) {h[i] = x_ob[i] - Teta_1[1]*x_ob[i-1] - Teta_1[2]*x_ob[i-2]}
Gar = garch(h, order = c(3, 0), start = A) # для оценивания вектора 𝐴 используем функцию 𝑔𝑎𝑟𝑐ℎ() по невязкам {ℎˆ𝑛}
A_1 = c(Gar$coef[1], Gar$coef[2], Gar$coef[3], Gar$coef[4])

#Разбиение на обучающую и тестовую выборки
#На основе обучающей выборки получить оценки параметров 𝜃 и 𝐴
library(rugarch)
train_size = round(length(AR_2))
train_data = AR_2[1:train_size]
test_data = AR_2[(train_size+1):length(AR_2)]
ar_model1 <- arima(train_data, order=c(2,0,0), method="ML")
Teta_11 = c(ar_model1$coef[1], ar_model1$coef[2])

A_1;Teta_1;Teta_11

#Построить последовательность прогнозов на один шаг на тестовой выборке. 
#Наложить последовательность прогнозов на последовательность наблюдений процесса
PR = function(x_test, Teta, a) 
{ x1 = array(dim = n_3)
  s = array(dim = n_3)
  lim_1 = array(dim = n_3) 
  lim_2 = array(dim = n_3)
  x1[1] = 0
  x1[2] = Teta[1]*x_test[1]
  x1[3] = Teta[1]*x_test[2] + Teta[2]*x_test[1]
  s[1] = a[1]
  s[2] = a[1] + a[2]*x_test[1]^2
  s[3] = a[1] + a[2]*x_test[2]^2 + a[3]*x_test[1]^2
  for(i in 4 : n_3) 
  {
    x1[i] = Teta[1]*x_test[i-1] + Teta[2]*x_test[i-2]
    s[i] = a[1] + a[2]*x_test[i-1]^2 + a[3]*x_test[i-2]^2 + a[4]*x_test[i-3]^2
  } 
  for(i in 1 : n_3) # рассчет границ
  {lim_1[i] = x1[i] + sqrt(s[i])
   lim_2[i] = x1[i] - sqrt(s[i])
  }
  plot(x_test, type = 'l',lwd = 2, col = 'turquoise', main = "Последовательность прогнозов и наблюдений")
  lines(x1, type = 'p', pch = 21, cex = 1,lwd = 2, col = 'black') 
  lines(lim_1, lty = 2, lwd = 2,col = 'red')
  lines(lim_2, lty = 2,lwd = 2, col = 'red')
}
plot(x_test, type = 'l',lwd = 2, col = 'turquoise', main = "Последовательность прогнозов и наблюдений")
PR1 = PR(x_test, Teta, A_1) 
legend("bottomright", legend = c("прогноз на 1 шаг", "граница низ и верх","Xn"),lwd = 3, col = c("black", "red","turquoise"))

# 5.Скачать любые дневные котировки финансовых активов или значения индексов (минимум за 3 года).
# 6.Импортировать скачанные данные в 𝑅, используя функцию 𝑟𝑒𝑎𝑑.𝑡𝑎𝑏𝑙𝑒()
# 7.Построить график динамики актива
#Индекс транспорта
par(mfrow = c(2, 1))
table = read.csv( "C:/Users/Admin/Desktop/7 семестр/ЭММ - 2/Лабораторные/MOEXTN_210118_240118.csv", sep = ";") 
str(table)
print(table)
N=nrow(table);N
activ = table$X.OPEN
plot(activ, type = 'l', main = "График динамики актива") 
activ1 = table$X.CLOSE
plot(activ1, type = 'l', main = "График динамики актива") 

#Привести данные к стационарному виду, используя одно из преобразований
z = array(dim =N)
z[1] = 0
for(k in 2 : N){z[k] = log(activ[k]/activ[k - 1])}
plot(z, type = 'l', main = "График доходностей {𝑧𝑘} финансового актива")

z1 = array(N)
z1[1] = 0
for(k1 in 2 : N)
  z1[k1] = (activ[k1] - activ[k1 - 1])/activ[k1 - 1]
plot(z1, type = 'l', main = "График доходностей {𝑧𝑘} финансового актива",col = 'turquoise')

#Повторить шаги 2-4 для последовательности {𝑧𝑛} при предположении,что процесс {𝑧𝑛} описывается моделью 𝐴𝑅(2)𝐴𝑅𝐶𝐻(3).
N
n2 = 6552;n2
n3 = 328; n3
x2_ob = z[1 : n2]
x2_test = z[(n2+1) : N]

ar_model_2 = arima(x2_ob, order = c(2, 0, 0), include.mean = FALSE) # для оценивания 𝜃 используем функцию 𝑎𝑟𝑖𝑚𝑎()
Teta_2 = c(ar_model_2$coef[1], ar_model_2$coef[2]); Teta_2

h2 = array(dim = n2)
h2[1] = x2_ob[1]
h2[2] = x2_ob[2] - Teta_2[1]*x2_ob[1]
for (i in 3 : n2) {h2[i] = x2_ob[i] - Teta_2[1]*x2_ob[i-1] - Teta_2[2]*x2_ob[i-2]}
Gar_2 = garch(h2, order = c(3, 0)) # для оценивания вектора 𝐴 используем функцию 𝑔𝑎𝑟𝑐ℎ() по невязкам {ℎˆ𝑛}
A_2 = c(Gar_2$coef[1], Gar_2$coef[2], Gar_2$coef[3], Gar_2$coef[4]); A_2

plot(x2_test, type = 'l', col = 'turquoise', main = "Последовательность прогнозов и наблюдений")
PR2 = PR(x2_test, Teta_2, A_2) 




