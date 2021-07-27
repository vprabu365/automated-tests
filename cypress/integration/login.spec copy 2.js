describe(`login scenario using task`, () => {
    before(() => {
    //    // cy.visit(`/home`);
    //     cy.task(`getSession`, {username: `studentm@dev-edu-peardeck.com`, password: `howdy235`, url: `https://qa.peardeck.dev/authPicker?finalDestinationUrl=%2Fhome%2F`}).then(session => {
    //         cy.restoreSession(session);
    //     })
    //    // cy.get('[data-qa="homeLinkTop"]').should('be.visible')
    })
    it(`login test`, () => {
        cy.visit(`/home`);
    })
});
