describe(`login scenario using task`, () => {

    it.only(`login test`, () => {
        cy.login();
        cy.visit(`/home`);
        cy.get('[data-qa="pdActivitiesHeader"]').should('be.visible')
        cy.get("[class='c-nav__profile__menu-arrow']").click();
        cy.get("[href='/auth/logout']").scrollIntoView().should('be.visible')
        cy.get("[href='/auth/logout']").click()
        cy.get('[data-qa="googleButton"]').should('be.visible')

        
    })
});
