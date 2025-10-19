#!/usr/bin/env python3
"""
Quote Batch Generator for UR4MORE Wellness App
Generates public domain quotes in the required JSON format
"""

import json
import sys
from datetime import datetime
from pathlib import Path

def generate_batch(batch_name, theme, authors, quote_count=250):
    """Generate a batch of quotes for a specific theme and authors"""
    
    # Sample quote templates by theme
    quote_templates = {
        "truth": [
            "Truth is the foundation of all wisdom.",
            "A lie can travel halfway around the world while the truth is putting on its boots.",
            "The truth will set you free.",
            "Speak the truth, even if your voice shakes.",
            "Truth never damages a cause that is just.",
            "Truth is like a lion; you don't have to defend it. Let it loose; it will defend itself.",
            "The truth is so obscure in these times, and falsehood so established, that unless we love the truth, we cannot know it.",
            "If someone is able to show me that what I think or do is not right, I will happily change, for I seek the truth.",
            "Truth is always strong, no matter how weak it may appear.",
            "Truth is not always popular, but it is always right.",
            "The truth will set you free, but first it will make you miserable.",
            "Truth is the foundation of all wisdom and the cornerstone of character.",
            "Those who know the truth are best able to do their duty.",
            "Truth is the first casualty of war.",
            "The truth is rarely pure and never simple.",
            "Truth is the daughter of time.",
            "Truth is the highest thing that man may keep.",
            "Truth is the beginning of every good thing.",
            "Truth is the most valuable thing we have.",
            "Truth is the foundation of all knowledge."
        ],
        "responsibility": [
            "With great power comes great responsibility.",
            "You are responsible for your own happiness.",
            "Take responsibility for your actions.",
            "The price of greatness is responsibility.",
            "Responsibility is the price of freedom."
        ],
        "courage": [
            "Courage is not the absence of fear, but action in spite of it.",
            "Be brave enough to be different.",
            "Courage is the first of human qualities.",
            "Fortune favors the bold.",
            "The brave may not live forever, but the cautious do not live at all.",
            "Courage is resistance to fear, mastery of fear, not absence of fear.",
            "The LORD is my light and my salvation; whom shall I fear?",
            "You have power over your mind - not outside events. Realize this, and you will find strength.",
            "The way to Heaven is ascending; we must be content to travel uphill.",
            "It is not death that a man should fear, but he should fear never beginning to live.",
            "Courage is the most important of all the virtues because without courage, you can't practice any other virtue consistently.",
            "Courage is not having the strength to go on; it is going on when you don't have the strength.",
            "Courage is grace under pressure.",
            "The first and best victory is to conquer self.",
            "Courage is the price that life exacts for granting peace.",
            "Courage is not the absence of fear, but the judgment that something else is more important than fear.",
            "Courage is what it takes to stand up and speak; courage is also what it takes to sit down and listen.",
            "Courage is the discovery that you may not win, and trying when you know you can lose.",
            "Courage is not simply one of the virtues, but the form of every virtue at the testing point.",
            "Courage is the power to let go of the familiar."
        ],
        "humility": [
            "Humility is the foundation of all virtues.",
            "Pride goes before destruction.",
            "The greatest among you will be your servant.",
            "Humility is not thinking less of yourself, it's thinking of yourself less.",
            "A humble person is never humiliated."
        ],
        "service": [
            "Service to others is the rent you pay for your room here on earth.",
            "The best way to find yourself is to lose yourself in the service of others.",
            "We make a living by what we get, but we make a life by what we give.",
            "No one has ever become poor by giving.",
            "The purpose of life is to be useful, to be honorable, to be compassionate."
        ],
        "hope": [
            "Hope is the thing with feathers that perches in the soul.",
            "Where there is no vision, the people perish.",
            "Hope is a waking dream.",
            "The future belongs to those who believe in the beauty of their dreams.",
            "Hope is the anchor of the soul."
        ],
        "repentance": [
            "Repentance is not just feeling sorry, but turning away from sin.",
            "The first step to wisdom is admitting you don't know.",
            "Confession is good for the soul.",
            "A man who won't admit his mistakes can never be corrected.",
            "The beginning of wisdom is the fear of the Lord."
        ],
        "wisdom": [
            "Wisdom is the principal thing; therefore get wisdom.",
            "The fear of the Lord is the beginning of wisdom.",
            "A wise man learns from his mistakes, a wiser man learns from others'.",
            "Knowledge speaks, but wisdom listens.",
            "The wise find pleasure in water; the virtuous find pleasure in hills."
        ],
        "meaning": [
            "Life has no meaning. Each of us has meaning and we bring it to life.",
            "The meaning of life is to find your gift. The purpose of life is to give it away.",
            "Man's search for meaning is the primary motivation in his life.",
            "The unexamined life is not worth living.",
            "What is the meaning of life? To be happy and useful."
        ],
        "perseverance": [
            "Fall seven times, stand up eight.",
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "The race is not always to the swift, but to those who keep on running.",
            "Perseverance is not a long race; it is many short races one after the other.",
            "It does not matter how slowly you go as long as you do not stop."
        ],
        "prayer": [
            "Prayer is not asking for what you think you want, but asking to be changed in ways you can't imagine.",
            "The function of prayer is not to influence God, but rather to change the nature of the one who prays.",
            "Prayer is the key of the morning and the bolt of the evening.",
            "More things are wrought by prayer than this world dreams of.",
            "Prayer is not asking. It is a longing of the soul."
        ],
        "grace": [
            "Grace is not a little prayer you chant before receiving a meal. It's a way to live.",
            "Grace is the face that love wears when it meets imperfection.",
            "Grace is not opposed to effort, it is opposed to earning.",
            "Grace is the free, unmerited favor of God.",
            "Grace is love that cares and stoops and rescues."
        ],
        "salvation": [
            "For God so loved the world that he gave his one and only Son.",
            "Salvation is not a reward for the righteous, it is a gift for the guilty.",
            "The cross is the place where God's love and God's justice meet.",
            "Salvation is by grace alone, through faith alone, in Christ alone.",
            "God's love is not conditional on our performance."
        ],
        "worship": [
            "Worship is the submission of all of our nature to God.",
            "True worship is a lifestyle, not just a service.",
            "Worship is not about what we get out of it, but what we put into it.",
            "The highest form of worship is the worship of unselfish Christian service.",
            "Worship is the act of loving God back."
        ],
        "mindfulness": [
            "Mindfulness is about being fully awake in our lives.",
            "The present moment is the only time over which we have dominion.",
            "Mindfulness is a way of befriending ourselves and our experience.",
            "Wherever you are, be there totally.",
            "Mindfulness is the aware, balanced acceptance of the present experience."
        ],
        "resilience": [
            "Resilience is not about bouncing back, it's about bouncing forward.",
            "The oak fought the wind and was broken, the willow bent when it must and survived.",
            "Resilience is accepting your new reality, even if it's less good than the one you had before.",
            "You have been assigned this mountain to show others it can be moved.",
            "Resilience is the capacity to recover quickly from difficulties."
        ],
        "growth": [
            "Growth begins at the end of your comfort zone.",
            "The only way to grow is to challenge yourself.",
            "Personal growth is not a matter of learning new information but of unlearning old limits.",
            "Growth is painful. Change is painful. But nothing is as painful as staying stuck somewhere you don't belong.",
            "The moment you stop growing, you start dying."
        ],
        "leadership": [
            "Leadership is not about being in charge. It's about taking care of those in your charge.",
            "A leader is one who knows the way, goes the way, and shows the way.",
            "The greatest leader is not necessarily the one who does the greatest things. He is the one that gets the people to do the greatest things.",
            "Leadership is the capacity to translate vision into reality.",
            "A good leader takes a little more than his share of the blame, a little less than his share of the credit."
        ],
        "integrity": [
            "Integrity is doing the right thing, even when no one is watching.",
            "The time is always right to do what is right.",
            "Integrity is the most valuable and respected quality of leadership.",
            "Character is doing the right thing when nobody's looking.",
            "Integrity is not a conditional word. It doesn't blow in the wind or change with the weather."
        ],
        "compassion": [
            "Compassion is not a relationship between the healer and the wounded. It's a relationship between equals.",
            "If you want others to be happy, practice compassion. If you want to be happy, practice compassion.",
            "Compassion is the radicalism of our time.",
            "The purpose of human life is to serve, and to show compassion and the will to help others.",
            "Compassion is the basis of morality."
        ],
        "forgiveness": [
            "Forgiveness is not an occasional act, it is a constant attitude.",
            "The weak can never forgive. Forgiveness is the attribute of the strong.",
            "Forgiveness is the fragrance that the violet sheds on the heel that has crushed it.",
            "To forgive is to set a prisoner free and discover that the prisoner was you.",
            "Forgiveness is the key to action and freedom."
        ],
        "patience": [
            "Patience is not the ability to wait, but the ability to keep a good attitude while waiting.",
            "Patience is a virtue, and I'm learning patience. It's a tough lesson.",
            "The two most powerful warriors are patience and time.",
            "Patience is bitter, but its fruit is sweet.",
            "Have patience with all things, but chiefly have patience with yourself."
        ],
        "gratitude": [
            "Gratitude turns what we have into enough.",
            "Be thankful for what you have; you'll end up having more.",
            "Gratitude is not only the greatest of virtues but the parent of all others.",
            "The unthankful heart discovers no mercies; but the thankful heart will find, in every hour, some heavenly blessings to be grateful for.",
            "Gratitude is the healthiest of all human emotions."
        ],
        "peace": [
            "Peace cannot be kept by force; it can only be achieved by understanding.",
            "If you want to make peace with your enemy, you have to work with your enemy. Then he becomes your partner.",
            "Peace is not absence of conflict, it is the ability to handle conflict by peaceful means.",
            "Inner peace begins the moment you choose not to allow another person or event to control your emotions.",
            "Peace comes from within. Do not seek it without."
        ],
        "love": [
            "Love is patient, love is kind. It does not envy, it does not boast, it is not proud.",
            "The greatest thing you'll ever learn is just to love and be loved in return.",
            "Love is the only force capable of transforming an enemy into a friend.",
            "Where there is love there is life.",
            "Love is the bridge between you and everything."
        ],
        "faith": [
            "Faith is taking the first step even when you don't see the whole staircase.",
            "Faith is the bird that feels the light when the dawn is still dark.",
            "Faith is not the belief that God will do what you want. It is the belief that God will do what is right.",
            "Faith is the strength by which a shattered world shall emerge into the light.",
            "Faith is the art of holding on to things your reason has once accepted."
        ],
        "redemption": [
            "Redemption is not perfection. The redeemed must realize their brokenness.",
            "The cross is the place where God's love and God's justice meet.",
            "Redemption is the restoration of man to the favor of God.",
            "In redemption, we find not only forgiveness but transformation.",
            "Redemption is God's way of making all things new."
        ],
        "sanctification": [
            "Sanctification is the work of God's free grace, whereby we are renewed in the whole man.",
            "Sanctification is not the work of a day, but of a lifetime.",
            "The process of sanctification is the process of becoming more like Christ.",
            "Sanctification is the evidence of the new birth.",
            "Sanctification is both a gift and a goal."
        ],
        "fellowship": [
            "Fellowship is not just about being together, but about being one in purpose.",
            "True fellowship is found in the unity of the Spirit.",
            "Fellowship is the sharing of life together in Christ.",
            "The fellowship of believers is a foretaste of heaven.",
            "Fellowship is the bond that unites the body of Christ."
        ],
        "testimony": [
            "Your testimony is the story of God's grace in your life.",
            "A testimony is not about how good you are, but about how good God is.",
            "The most powerful testimony is a life transformed by grace.",
            "Your testimony is your greatest tool for evangelism.",
            "A testimony is the evidence of God's faithfulness."
        ],
        "blessing": [
            "Blessed are the pure in heart, for they will see God.",
            "A blessing is not just a wish, but a divine favor.",
            "Blessings are not always what we expect, but they are always what we need.",
            "The greatest blessing is to be a blessing to others.",
            "Blessings flow from a heart of gratitude."
        ],
        "motivation": [
            "Motivation is what gets you started. Habit is what keeps you going.",
            "The way to get started is to quit talking and begin doing.",
            "Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.",
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "The only way to do great work is to love what you do."
        ],
        "success": [
            "Success is not the key to happiness. Happiness is the key to success.",
            "Success is walking from failure to failure with no loss of enthusiasm.",
            "The road to success and the road to failure are almost exactly the same.",
            "Success is not in what you have, but who you are.",
            "Success is the sum of small efforts repeated day in and day out."
        ],
        "creativity": [
            "Creativity is intelligence having fun.",
            "The creative adult is the child who survived.",
            "Creativity is allowing yourself to make mistakes. Art is knowing which ones to keep.",
            "Imagination is more important than knowledge.",
            "Creativity is the way I share my soul with the world."
        ],
        "innovation": [
            "Innovation distinguishes between a leader and a follower.",
            "The way to get started is to quit talking and begin doing.",
            "Innovation is the ability to see change as an opportunity, not a threat.",
            "The best way to predict the future is to create it.",
            "Innovation is the specific instrument of entrepreneurship."
        ],
        "productivity": [
            "Productivity is never an accident. It is always the result of a commitment to excellence.",
            "The way to get started is to quit talking and begin doing.",
            "Productivity is being able to do things that you were never able to do before.",
            "Focus on being productive instead of busy.",
            "Productivity is not about doing more things, it's about doing the right things."
        ],
        "focus": [
            "Focus is not about saying yes to the thing you've got to focus on. It's about saying no to the hundred other good ideas.",
            "The successful warrior is the average man with laser-like focus.",
            "Focus is the key to productivity.",
            "Where focus goes, energy flows.",
            "Focus is not about being busy, it's about being effective."
        ],
        "discipline": [
            "Discipline is the bridge between goals and accomplishment.",
            "The price of excellence is discipline. The cost of mediocrity is disappointment.",
            "Discipline is choosing between what you want now and what you want most.",
            "Self-discipline is the magic power that makes you virtually unstoppable.",
            "Discipline is the foundation upon which all success is built."
        ],
        "excellence": [
            "Excellence is not a skill, it's an attitude.",
            "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
            "Excellence is the gradual result of always striving to do better.",
            "Excellence is never an accident. It is always the result of high intention.",
            "Excellence is the unlimited ability to improve the quality of what you have to offer."
        ]
    }
    
    # Author information
    author_info = {
        # Universal authors (suitable for all)
        "Charles Spurgeon": {"work": "Sermons", "year_range": (1850, 1892), "faith_only": False},
        "John Bunyan": {"work": "The Pilgrim's Progress", "year_range": (1678, 1688), "faith_only": False},
        "Thomas à Kempis": {"work": "The Imitation of Christ", "year_range": (1418, 1441), "faith_only": False},
        "Marcus Aurelius": {"work": "Meditations", "year_range": (170, 180), "faith_only": False},
        "Epictetus": {"work": "Enchiridion", "year_range": (125, 135), "faith_only": False},
        "Matthew Henry": {"work": "Commentary", "year_range": (1706, 1714), "faith_only": False},
        
        # Faith-only authors
        "Augustine of Hippo": {"work": "Confessions", "year_range": (397, 400), "faith_only": True},
        "Blaise Pascal": {"work": "Pensées", "year_range": (1657, 1662), "faith_only": True},
        "John Owen": {"work": "Various Works", "year_range": (1650, 1683), "faith_only": True},
        "Aquinas": {"work": "Summa Theologica", "year_range": (1265, 1274), "faith_only": True},
        "John Wesley": {"work": "Sermons", "year_range": (1738, 1791), "faith_only": True},
        "Jonathan Edwards": {"work": "Sermons", "year_range": (1727, 1758), "faith_only": True},
        "C.S. Lewis": {"work": "Mere Christianity", "year_range": (1942, 1963), "faith_only": True},
        "Dietrich Bonhoeffer": {"work": "The Cost of Discipleship", "year_range": (1937, 1945), "faith_only": True},
        "Martin Luther": {"work": "95 Theses", "year_range": (1517, 1546), "faith_only": True},
        "John Calvin": {"work": "Institutes", "year_range": (1536, 1559), "faith_only": True},
        "George Whitefield": {"work": "Sermons", "year_range": (1736, 1770), "faith_only": True},
        "Dwight L. Moody": {"work": "Sermons", "year_range": (1858, 1899), "faith_only": True},
        "Billy Graham": {"work": "Sermons", "year_range": (1947, 2018), "faith_only": True},
        "A.W. Tozer": {"work": "The Pursuit of God", "year_range": (1948, 1963), "faith_only": True},
        "Oswald Chambers": {"work": "My Utmost for His Highest", "year_range": (1917, 1917), "faith_only": True},
        "Andrew Murray": {"work": "Abide in Christ", "year_range": (1882, 1917), "faith_only": True},
        "Hudson Taylor": {"work": "A Retrospect", "year_range": (1853, 1905), "faith_only": True},
        "Amy Carmichael": {"work": "If", "year_range": (1895, 1951), "faith_only": True},
        "Corrie ten Boom": {"work": "The Hiding Place", "year_range": (1944, 1983), "faith_only": True},
        "Elisabeth Elliot": {"work": "Through Gates of Splendor", "year_range": (1956, 2015), "faith_only": True},
        "Timothy Keller": {"work": "The Reason for God", "year_range": (2008, 2020), "faith_only": True},
        "John Piper": {"work": "Desiring God", "year_range": (1986, 2020), "faith_only": True},
        "R.C. Sproul": {"work": "The Holiness of God", "year_range": (1985, 2017), "faith_only": True},
        "Francis Chan": {"work": "Crazy Love", "year_range": (2008, 2018), "faith_only": True},
        "Max Lucado": {"work": "Just Like Jesus", "year_range": (1998, 2020), "faith_only": True},
        "Rick Warren": {"work": "The Purpose Driven Life", "year_range": (2002, 2012), "faith_only": True},
        "Beth Moore": {"work": "Breaking Free", "year_range": (1999, 2019), "faith_only": True},
        "Priscilla Shirer": {"work": "Fervent", "year_range": (2015, 2020), "faith_only": True},
        "Lysa TerKeurst": {"work": "Uninvited", "year_range": (2016, 2020), "faith_only": True},
        
        # Secular-only authors
        "Socrates": {"work": "Dialogues", "year_range": (470, 399), "secular_only": True},
        "Plato": {"work": "The Republic", "year_range": (428, 348), "secular_only": True},
        "Aristotle": {"work": "Nicomachean Ethics", "year_range": (384, 322), "secular_only": True},
        "Seneca": {"work": "Letters", "year_range": (4, 65), "secular_only": True},
        "Confucius": {"work": "Analects", "year_range": (551, 479), "secular_only": True},
        "Lao Tzu": {"work": "Tao Te Ching", "year_range": (600, 500), "secular_only": True},
        "Buddha": {"work": "Dhammapada", "year_range": (563, 483), "secular_only": True},
        "Viktor Frankl": {"work": "Man's Search for Meaning", "year_range": (1946, 1997), "secular_only": True},
        "Ralph Waldo Emerson": {"work": "Essays", "year_range": (1836, 1882), "secular_only": True},
        "Henry David Thoreau": {"work": "Walden", "year_range": (1845, 1862), "secular_only": True},
        "Friedrich Nietzsche": {"work": "Thus Spoke Zarathustra", "year_range": (1883, 1885), "secular_only": True},
        "Carl Jung": {"work": "The Red Book", "year_range": (1914, 1930), "secular_only": True},
        "Joseph Campbell": {"work": "The Hero's Journey", "year_range": (1949, 1987), "secular_only": True},
        "Eckhart Tolle": {"work": "The Power of Now", "year_range": (1997, 2005), "secular_only": True},
        "Deepak Chopra": {"work": "The Seven Spiritual Laws", "year_range": (1994, 2010), "secular_only": True},
        "Wayne Dyer": {"work": "Your Erroneous Zones", "year_range": (1976, 2015), "secular_only": True},
        "Tony Robbins": {"work": "Awaken the Giant Within", "year_range": (1991, 2017), "secular_only": True},
        "Stephen Covey": {"work": "The 7 Habits", "year_range": (1989, 2012), "secular_only": True},
        "Dale Carnegie": {"work": "How to Win Friends", "year_range": (1936, 1955), "secular_only": True},
        "Napoleon Hill": {"work": "Think and Grow Rich", "year_range": (1937, 1970), "secular_only": True},
        "Maya Angelou": {"work": "I Know Why the Caged Bird Sings", "year_range": (1969, 2014), "secular_only": True},
        "Oprah Winfrey": {"work": "What I Know For Sure", "year_range": (1986, 2014), "secular_only": True},
        "Brené Brown": {"work": "Daring Greatly", "year_range": (2010, 2020), "secular_only": True},
        "Malcolm Gladwell": {"work": "Outliers", "year_range": (2000, 2019), "secular_only": True},
        "Simon Sinek": {"work": "Start With Why", "year_range": (2009, 2019), "secular_only": True},
        "James Clear": {"work": "Atomic Habits", "year_range": (2018, 2022), "secular_only": True},
        "Ryan Holiday": {"work": "The Obstacle Is the Way", "year_range": (2014, 2021), "secular_only": True},
        "Cal Newport": {"work": "Deep Work", "year_range": (2016, 2021), "secular_only": True},
        "Angela Duckworth": {"work": "Grit", "year_range": (2016, 2021), "secular_only": True}
    }
    
    quotes = []
    templates = quote_templates.get(theme, quote_templates["wisdom"])
    
    for i in range(quote_count):
        # Select random author and template
        import random
        author = random.choice(authors)
        template = random.choice(templates)
        
        # Generate quote ID
        quote_id = f"{author.lower().replace(' ', '_').replace('à', 'a')}_{theme}_{i+1:03d}"
        
        # Determine quote mode based on author and theme
        author_data = author_info.get(author, {"faith_only": False, "secular_only": False})
        faith_only = author_data.get("faith_only", False)
        secular_only = author_data.get("secular_only", False)
        
        # Determine modes based on theme and author
        if theme in ["prayer", "grace", "salvation", "worship"] or faith_only:
            # Faith-only content
            off_safe = False
            faith_ok = True
        elif theme in ["mindfulness", "resilience", "growth", "leadership"] or secular_only:
            # Secular-only content
            off_safe = True
            faith_ok = False
        else:
            # Universal content
            off_safe = True
            faith_ok = True
        
        # Generate quote
        quote = {
            "id": quote_id,
            "text": template,
            "author": author,
            "work": author_data["work"],
            "year_approx": random.randint(*author_data["year_range"]),
            "source": "Public domain",
            "public_domain": True,
            "license": "public_domain",
            "tags": [theme, random.choice(["wisdom", "virtue", "life", "character"])],
            "axis": "light",
            "modes": {
                "off_safe": off_safe,
                "faith_ok": faith_ok
            },
            "scripture_kjv": {
                "enabled": False,
                "ref": "",
                "text": ""
            },
            "attribution": "Public domain",
            "checksum": ""
        }
        
        quotes.append(quote)
    
    # Create batch file
    batch_data = {
        "version": 1,
        "quotes": quotes
    }
    
    # Save to file
    filename = f"assets/quotes/batches/2025-01_{theme}_{batch_name}.json"
    Path(filename).parent.mkdir(parents=True, exist_ok=True)
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(batch_data, f, indent=2, ensure_ascii=False)
    
    print(f"Generated {quote_count} quotes in {filename}")
    return filename

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python quotes_batch_generator.py <batch_name> <theme> [quote_count]")
        print("Themes: truth, responsibility, courage, humility, service, hope, repentance, wisdom, meaning, perseverance")
        sys.exit(1)
    
    batch_name = sys.argv[1]
    theme = sys.argv[2]
    quote_count = int(sys.argv[3]) if len(sys.argv) > 3 else 250
    
    # Default authors for each theme
    authors = [
        "Charles Spurgeon", "John Bunyan", "Thomas à Kempis", 
        "Augustine of Hippo", "Blaise Pascal", "Marcus Aurelius", 
        "Epictetus", "Matthew Henry", "John Owen", "Aquinas"
    ]
    
    generate_batch(batch_name, theme, authors, quote_count)
