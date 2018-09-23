---
title: HDU 1045(Fire Net)题解
categories: 算法题解
tags: [算法题解]
date: 2015-08-10 15:12:00
---
嘛..markdown爽..那就再爽一次..
相应博客园url：[这里](http://www.cnblogs.com/blumia/p/hdu1045.html)
题解写的越发的少了，主要也只是因为题写的慢了..莫名其妙的动力减少以及难度增加导致的做题缓慢什么的.. ~~趁着这回写一次凑个数吧~~
以防万一，题目原文和链接均附在文末。那么先是题目分析：

<!--more-->

## 【一句话题意】

给定大小的棋盘中部分格子存在可以阻止互相攻击的墙，问棋盘中可以放置最多多少个可以横纵攻击炮塔。

## 【题目分析】

这题本来在搜索专题里出现的..这回又在二分查找匹配专题出现了..所以当然要按照二分匹配的方法解而不是爆搜（虽然爆搜能过）。
问题主要就是如何缩点建图。为了使得blockhouse不能互相攻击，那么使用每行的相邻的点缩点，每列的相邻的点缩点，连边的条件就是两个点存在有相交的部分，最后这两组点求最大匹配就行了。

## 【算法流程】

应该这题也能算是标准题了吧。缩点，建图，hungary匈牙利算法求解，输出答案。完事儿了。
匈牙利算法以及二分最大匹配的相关内容这里就不说了。。

下面的代码简单说明，本来的aleft和aright名字叫left和right，后来发现和STL的东西冲突了。。
fill的宏定义有更科学的方法，这里就只是单纯的抹0。以及for each是从1到n而不是从0到n。
因为习惯问题，数组是从1算起的。

``` cpp
	#include <cstdio>
	#include <cstdlib>
	#include <iostream>
	#include <cstring>
	#include <queue>
	#include <algorithm>
	#include <vector>
	#define each(i,n) (int i=1;i<=(n);++i)
	#define fill(arr) memset(arr,0,sizeof(arr))
	#define INF 0x3f3f3f3f
	
	char map[6][6];
	char aleft[6][6];
	char aright[6][6];
	int l[61], r[61], lCnt, rCnt;
	bool graph[61][61];
	bool vis[61];
	
	using namespace std;
	
	int dfs(int left) {
		for each(right,rCnt) {
			//left到right有路且没遍历过 
			if(graph[left][right] && !vis[right]) {
				vis[right] = true;
				//若right还没匹配过或跟right匹配的点找到另一个相匹配的点
				//(则right就可以跟left匹配) 
				if(r[right]==-1 || dfs(r[right])) {
					r[right] = left;
					l[left] = right;
					//printf("(%d,%d)\n",left,right); 
					return 1;
				}
			}
		}
		return 0;
	}
	
	int hungary() {
		int ans = 0;
		memset(l,-1,sizeof(l));
		memset(r,-1,sizeof(r));	
		for each(i,lCnt) { //row point cnt
			if(l[i] == -1) {
				fill(vis);
				ans += dfs(i);
			}
		}
		return ans;
	}
	
	int main() {
	
		int n;
		char buffer[10];
		while(gets(buffer)) {
			//proc input
			if (buffer[0] == '0') break;
			sscanf(buffer,"%d",&n);
			for each(line,n) {
				gets(buffer);
				for each(col,n) {
					map[line][col] = buffer[col-1];
				}
			}
			//create grapth [ Marking up Points ] 
			fill(aleft);
			fill(aright);
			lCnt = 1;
			int pre = 0;
			for each(row,n) {
				for each(col,n) {
					if(map[row][col]=='X') {
						if(pre==lCnt) ++lCnt;
						continue;
					}
					aleft[row][col] = lCnt;
					pre = lCnt;
				}
				if(pre==lCnt) ++lCnt;
			}
			lCnt = pre;
			rCnt = 1;
			pre = 0;
			for each(col,n) {
				for each(row,n) {
					if(map[row][col]=='X') {
						if(pre==rCnt) ++rCnt;
						continue;
					}
					aright[row][col] = rCnt;
					pre = rCnt;
				}
				if(pre==rCnt) ++rCnt;
			}
			rCnt = pre;
			//create grapth [ Shrinking Points ]
			fill(graph);
			for each(row,n) {
				for each(col,n) {
					if(map[row][col]=='.')
						graph[aleft[row][col]][aright[row][col]] = true;
				}
			}
			//doWork
			printf("%d\n",hungary());
		}
	
	}
```
-------------------

题目链接：[Fire Net（HDU 1045）](http://acm.hdu.edu.cn/showproblem.php?pid=1045)

题目属性：二分图最大匹配 （如果愿意你可以去爆搜..）

相关题目：2444 1083 1281 2819 2389 4185 poj3020 ...

题目原文：
【desc】
Suppose that we have a square city with straight streets. A map of a city is a square board with n rows and n columns, each representing a street or a piece of wall. 

A blockhouse is a small castle that has four openings through which to shoot. The four openings are facing North, East, South, and West, respectively. There will be one machine gun shooting through each opening. 

Here we assume that a bullet is so powerful that it can run across any distance and destroy a blockhouse on its way. On the other hand, a wall is so strongly built that can stop the bullets. 

The goal is to place as many blockhouses in a city as possible so that no two can destroy each other. A configuration of blockhouses is legal provided that no two blockhouses are on the same horizontal row or vertical column in a map unless there is at least one wall separating them. In this problem we will consider small square cities (at most 4x4) that contain walls through which bullets cannot run through. 

The following image shows five pictures of the same board. The first picture is the empty board, the second and third pictures show legal configurations, and the fourth and fifth pictures show illegal configurations. For this board, the maximum number of blockhouses in a legal configuration is 5; the second picture shows one way to do it, but there are several other ways. 

![看我多良心，还给备个图][1]

Your task is to write a program that, given a description of a map, calculates the maximum number of blockhouses that can be placed in the city in a legal configuration. 
【In】
The input file contains one or more map descriptions, followed by a line containing the number 0 that signals the end of the file. Each map description begins with a line containing a positive integer n that is the size of the city; n will be at most 4. The next n lines each describe one row of the map, with a '.' indicating an open space and an uppercase 'X' indicating a wall. There are no spaces in the input file.
【Out】
For each test case, output one line containing the maximum number of blockhouses that can be placed in the city in a legal configuration.
【SampIn】
<pre>4
.X..
....
XX..
....
2
XX
.X
3
.X.
X.X
.X.
3
...
.XX
.XX
4
....
....
....
....
0</pre>
【SampOut】
<pre>5
1
5
2
4</pre>


  [1]: http://blogblumia-typecho.stor.sinaapp.com/usr/uploads/2015/08/2630942644.jpg
