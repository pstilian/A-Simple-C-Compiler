#include <stdlib.h>
#include <stdio.h>
#include "ast.h"


/* Create a newAST object */
ASTree *newAST(ASTNodeType t, ASTree *child, unsigned int natAttribute, char *idAttribute, unsigned int lineNum)
{
    /*Alloc Memory for the AST */
    ASTree *newTreeNode = malloc(sizeof(ASTree));


    if(!newTreeNode)
    {
        printf("Failed to allocate\n");
        exit(0);
    }

    /*Set type of the AST */
    newTreeNode->typ = t;


    /*Check if there is a child parameter*/
    if(child)
    {
        /*Set up single child node */
        newTreeNode->children = malloc(sizeof(ASTList));

        /*Check that allocation was successful */
        if(newTreeNode->children)
        {
            newTreeNode->children->data = child;
            newTreeNode->children->next = 0;

            /* Point tail to single node */
            newTreeNode->childrenTail = newTreeNode->children;
        }
        /*Check for memory */
        else
        {
            printf("failed to allocate memory\n");
            exit(0);
        }

    }
    /*If no child parameter set members accordingly */
    else
    {
        newTreeNode->children = 0;
        newTreeNode->childrenTail = 0;
    }

    /*Set natVal member if this is a NAT_LITERAL_EXPR AST */
    if(t == NAT_LITERAL_EXPR || t == TRUE_LITERAL_EXPR || t == FALSE_LITERAL_EXPR)
    {
        newTreeNode->natVal = natAttribute;
    }
    /*Set idVal if this is an AST_ID AST */
    else if (t == AST_ID)
    {
        newTreeNode->idVal = idAttribute;
    }

    /* Set the line number attribute */
    newTreeNode->lineNumber = lineNum;

    return newTreeNode;
}


/*Append a child AST to a parent AST */
ASTree *appendToChildrenList(ASTree *parent, ASTree *newChild)
{
    /*Allocate memory for the new node */
    ASTList *newListNode = malloc(sizeof(ASTList));

    if(!newListNode)
    {
        printf("Failed to allocate memory\n");
        exit(0);
    }

    /*Set old node next to point to new node*/
    /*Make sure to check null case as well */
    if(parent->childrenTail)
    {
        parent->childrenTail->next = newListNode;
    }

    
    if(!parent->children)
    {
        parent->children = newListNode;
    }

    /* Set new tail pointer to newNode that is appended */
    parent->childrenTail = newListNode;

    /*Initialize newNode fields */
    newListNode->data = newChild;
    newListNode->next = 0;

    return parent;

}

void EnumToString(ASTree* t)
{
    if(t == NULL)
        return;
    switch(t->typ)
    {
        case 0: printf("PROGRAM"); break;
        case 1: printf("CLASS_DECL_LIST"); break;
        case 2: printf("CLASS_DECL"); break;
        case 3: printf("STATIC_VAR_DECL_LIST"); break;
        case 4: printf("STATIC_VAR_DECL"); break;
        case 5: printf("VAR_DECL_LIST"); break;
        case 6: printf("VAR_DECL"); break;
        case 7: printf("METHOD_DECL_LIST"); break;
        case 8: printf("METHOD_DECL"); break;
        case 9: printf("NAT_TYPE"); break;
        case 10: printf("BOOL_TYPE"); break;
        case 11: printf("AST_ID(%s)", t->idVal) ; break;
        case 12: printf("EXPR_LIST"); break;
        case 13: printf("DOT_METHOD_CALL_EXPR"); break;
        case 14: printf("METHOD_CALL_EXPR"); break;
        case 15: printf("DOT_ID_EXPR"); break;
        case 16: printf("ID_EXPR"); break;
        case 17: printf("DOT_ASSIGN_EXPR"); break;
        case 18: printf("ASSIGN_EXPR"); break;
        case 19: printf("PLUS_EXPR"); break;
        case 20: printf("MINUS_EXPR"); break;
        case 21: printf("TIMES_EXPR"); break;
        case 22: printf("EQUALITY_EXPR"); break;
        case 23: printf("GREATER_THAN_EXPR"); break;
        case 24: printf("NOT_EXPR"); break;
        case 25: printf("AND_EXPR"); break;
        case 26: printf("INSTANCEOF_EXPR"); break;
        case 27: printf("IF_THEN_ELSE_EXPR"); break;
        case 28: printf("FOR_EXPR"); break;
        case 29: printf("PRINT_EXPR"); break;
        case 30: printf("READ_EXPR"); break;
        case 31: printf("THIS_EXPR"); break;
        case 32: printf("NEW_EXPR"); break;
        case 33: printf("NULL_EXPR"); break;
        case 34: printf("NAT_LITERAL_EXPR(%d)", t->natVal); break;
        case 35: printf("TRUE_LITERAL_EXPR"); break;
        case 36: printf("FALSE_LITERAL_EXPR"); break;
        default: printf("Error");
    }
            
}

/* print tree in preorder */
void printASTree(ASTree *t, int depth) {
    if(t == NULL) 
        return;


    printf("%d:",depth);

    int i=0;
    for(; i<depth; i++) { printf("  "); }

    EnumToString(t);
    printf(" (ends on line %d)", t->lineNumber);
    printf("\n");
    //recursively print all children
    ASTList *childListIterator = t->children;
    while(childListIterator!=NULL) {
        
        printASTree(childListIterator->data, depth+1);
        childListIterator = childListIterator->next;
    }
}


/* Print the AST to stdout with indentations marking tree depth */
void printAST(ASTree *t)
{
    printASTree(t, 0);
}
