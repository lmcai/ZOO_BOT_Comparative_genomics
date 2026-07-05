# Final project report guideline

This is a guideline for writing your GitHub summary page for your final project. Overall speaking, it should follow an Introduction-Methods-Results/Discussion structure.

_______________________________

# Title of the project

The title should be succinct and informative. What is the organism you are working with? What hypothesis do you want to test? What conclusion have you reached?

## I. Introduction (maximum 200 words)

Frame your question and connect it with the literature. Why is this question important? How would you address the knowledge gap? Why is this an appropriate system to address this question? 

## II. Methods (unlimited words)

Clearly describe your data source and analyses here. When describing an analysis, consider including the following components: 

- Input data: What is the input data? Where did you find these data? Did you take any actions to reformat it for the analysis?
- Software: What computational program did you use? Which version? Using what parameters?
- Command lines: You can record the command lines you used for the analysis in GitHub like this:
```
software input > output
```

## III. Results and discussion (maximum 500 words)

Describe the results from the above analyses and your interpretation. 

For tables and figures, make sure you have captions. In a GitHub markdown file, you can add tables like this:
```
**Table 1** Test table caption
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| A        | B        | C        |
| D        | E        | F        |
```
The double stars `**` quote the text that needs to be in bold font. The pipes `|` and underscores `_` delineate the columns and title rows. This table will be displayed like this:

**Table 1** Test table caption

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| A        | B        | C        |
| D        | E        | F        |

You can add figures like this:
```
![Alt text for figure](misc/test.png)

**Figure 1** Test figure caption
```
The `![]` signs ask Markdown to look for a figure to display. The path in the parenthesis `(misc/test.png)` points Markdown to the relative path of the file, which is stored in the folder `misc` and named as `test.png`. The figure will be displayed like this:

![Alt text for figure](misc/test.png)

**Figure 1** Test figure caption

## Reference

Cite at least 10 references throughout the summary. 

When do you need to cite?
- Introducing what others did in the past
- Citing a method/software
- Comparing your results to others
- Many more