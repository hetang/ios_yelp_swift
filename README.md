# Yelp Client Codepath
### User can view a list of business nearby. As well as they can filter result by applying distance, sort, category or deal filter.

Time spent: 16 hrs spent

Completed User Stories:
- Search results page
    - Table rows are dynamic height according to the content height.
    - Search bar is in the navigation bar
    - Infinite scroll for business results
    - User can toggle between map & list view.
- Filter page.
    - The filters are: category, sort (best match, distance, highest rated), distance, deals (on/off).
    - The filters table are organized into sections
    - Clicking on the "Apply" button is dismissing the filters page and triggering search with the new filter settings.

Walkthrough of all user stories:

![Video Walkthrough](yelp_recording.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Yelp API

- Check out `BusinessPresenters.swift` to see how to use the `Business` model.

### Sample request

**Basic search with query**

```
Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
    self.businesses = businesses
    
    for business in businesses {
        print(business.name!)
        print(business.address!)
    }
})
```

**Advanced search with categories, sort, and deal filters**

```
Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in

    for business in businesses {
        print(business.name!)
        print(business.address!)
    }
}
```
