def geom_point(data, x, y, xlab=None, ylab=None, title=None, col=None, fill=None, group=None, alpha='auto'):
    """ Produces a Scatterplot.
    
     Args:
        data: The pandas dataframe
        x: Feature/Variable for the x axis
        y: Feature/Variable for the y axis

    Returns:
        A matplotlib plot!
    
    """
    sns.scatterplot(data[x], data[y],
                   palette=col, alpha=alpha)
    
    # Color and Fill
    if col!=None:
        plt.plot(c=col)    
    
    # Labels
    if xlab==None:
        plt.xlabel(x)
    else:
        plt.xlabel(xlab)
    if ylab==None:
        plt.ylabel(y)
    else:
        plt.ylabel(ylab)
    if title==None:
        plt.title('')
    else:
        plt.title(title)
